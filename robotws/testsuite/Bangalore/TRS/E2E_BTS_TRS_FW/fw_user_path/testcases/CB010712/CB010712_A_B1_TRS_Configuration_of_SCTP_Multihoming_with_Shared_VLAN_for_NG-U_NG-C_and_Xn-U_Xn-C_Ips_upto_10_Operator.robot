*** Settings ***
Documentation
...		[Author]     		        "Shreya Choudhary"
...		[Maintenance]		        "TRS I&V Tools Bangalore Team"
...		[Date] 			            "01-05-2024"
...		[QC_Path]                   "QC_Path in Test Plan"
...		[QC_ID]			            "QC_ID in Test Lab for reporting"
...		[Feature_ID] 		        "CB010712"
...     [Validated_TestLine]        "KVM65-TRSIV-TL007"
...		[Procedure]   		        "TRS_Commissioning_SgNB_with_Dual_Stack_for_all_the_RATs"
...     [Precondition]              "ASOE + AEQN hardware is required"
...     [Config_Comments]           "Shared VLAN NG-U NG-C Xn-U and Xn-C IPs for 10 Operators_IPv4"
...     [Function_Hash_Tags]        "SA 10 Operator RAN Sharing, Dual Stack, SCTP, verify 10 operator call with Airphone"


Resource    	${CURDIR}/resources/CB010712_common_keywords.robot

Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown	Run Keywords	Suite Teardown Postconditions
...		AND		Teardown Oamops

*** Variables ***
${routes}         ${CURDIR}/resources/asoe_sctp_routes.sh
${primary_amf_del}     ${CURDIR}/resources/asoe_amf_del_primary.sh
${primary_amf_add}     ${CURDIR}/resources/asoe_amf_add_primary.sh
${profile}        Configuration_SCTP_Multihoming_SA_NSA
*** Test Cases ***
[1]CB010712_A_B1_TRS_Configuration_of_SCTP_Multihoming_with_Shared_VLAN_for_NG-U_NG-C_and_Xn-U_Xn-C_Ips_upto_10_Operator
    Add Interfaces on VM
	Perform Commissioning       scf_file=${Configuration_ASOE_scf_basic}    verify_bts_status=False     timeout=360
	Sleep    240
    Perform Recommissioning     type=delta      delta_file=${Configuration_6_Operator_SCTP}    verify_bts_status=False     timeout=240
    Sleep    240
    Call Setup      5g=${profile}:data    parallel=${False}     verify_attach=${False}     attach=${False}
	Sleep   120
	Configure UE       5g=${profile}:data  command=enb_x2_link_up   target=2    enb=1
	Verify NG link Status      12
	Verify X2 link Status      1
	Configure and Verify SCTP Multihoming for Additional Operator
	Verify NG link Status      20
    Make Primary AMF link down and verify alarms
    Perform Recommissioning     type=param     param_path=NRBTS-1:actDynamicFirewall     operation=update     value=true    timeout=180
    Sleep   30
    Perform Recommissioning     type=delta    delta_file=${Configuration_delta_ipv4_amf}      timeout=300
    Trigger and Verify Random SA IPv4 call   1   10    4
    Perform Recommissioning     type=delta    delta_file=${Configuration_delta_ipv6_amf}      timeout=300
    Trigger and Verify Random SA IPv6 call   1   10    4
	[TEARDOWN]    Keyword to Run at end

*** Keywords ***
Add Interfaces on VM
	Delete Interfaces
	Run     sh ${routes}

Make Primary AMF link down and verify alarms
    Run     sh ${primary_amf_del}
    Wait Until Keyword Succeeds     180    10      Verify Alarm     faultid=7330   severity=major     should_exist=True    occurrences=20
    Verify NG link Status      20
    Run     sh ${primary_amf_add}
    Sleep  180
    Wait Until Keyword Succeeds     600    10      Verify Alarm     faultid=7330   should_exist=False

Configure and Verify SCTP Multihoming for Additional Operator
    Traffic Capture Start	  capture_device=oam_device	   mode=file	 measurement_point=NE_Terminated	 uplane_capturing=${True}
    ...    timeout=120    alias=point_B_sctp
	Perform Recommissioning     type=delta      delta_file=${Configuration_10_Operator_SCTP}       timeout=120
    Sleep   300
	${pcap_file}=       Traffic Capture Stop	  mode=file	  alias=point_B_sctp   timeout=120
	Get IP Address
    FOR   ${operator}   IN RANGE   0   20
	    ${ngcplane_ip}=	Get from List     ${NGC_IP_List}       ${operator}
		${amf_ip}=		Get from List     ${AMF_IP_List}       ${operator}
	    Get IP Version      ${amf_ip}
		Analyse Pcap        pcap_filename=${pcap_file}     analysis=sctp_init_${version}         filter_file_name=${traffic_filter_file_name}
		Analyse Pcap        pcap_filename=${pcap_file}     analysis=sctp_ack_${version}      filter_file_name=${traffic_filter_file_name}
	    Analyse Pcap        pcap_filename=${pcap_file}     analysis=sctp_heartbeat_${version}         filter_file_name=${traffic_filter_file_name}
	    Analyse Pcap        pcap_filename=${pcap_file}     analysis=sctp_heartbeat_ack_${version}     filter_file_name=${traffic_filter_file_name}
	    ${ngcplane_ip}=	Get from List     ${NGC_IP2_List}       ${operator}
	    ${amf_ip}=		Get from List     ${AMF_IP2_List}       ${operator}
	    Get IP Version      ${amf_ip}
	    Analyse Pcap      pcap_filename=${pcap_file}     analysis=sctp_heartbeat_${version}         filter_file_name=${traffic_filter_file_name}
	    Analyse Pcap      pcap_filename=${pcap_file}     analysis=sctp_heartbeat_ack_${version}     filter_file_name=${traffic_filter_file_name}
	END

Get IP Address
	Get AMF IP Address       20
	Get NG-U IP Address      10
	Get NG-C IP Address      10
	Get NG-C Secondary IP Address      10
	Get AMF Multihome IP Address      20

Keyword to Run at end
    Delete Interfaces
    Run     sudo killall edaemon egate
	Run Keyword And Ignore Error         Traffic capture stop	  alias=slice_${operator_str}
    Run Keyword And Ignore Error     Stop traffic and detach UE         ${operator}    ${profile}