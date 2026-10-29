*** Settings ***
Documentation
...		[Author]     		        "Nupur"
...		[Maintenance]		        "TRS I&V Tools Bangalore Team"
...		[Date] 			            "10:12:2022"
...		[QC_Path]                   "QC_Path in Test Plan"
...		[QC_ID]			            "QC_ID in Test Lab for reporting"
...		[Feature_ID] 		        "SR001395"
...     [Validated_TestLine]        "ASIM-TL-001"
...		[Procedure]   		        "LTE3065_R_a_X2_666_handover_and_Handover_TAC_check_for_all_operators"
...     [Precondition]              "ASIM+ABIO with AHFIB IPHY hardware is required"
...     [Config_Comments]           "LTE3065_R_a_X2_666_handover_and_Handover_TAC_check_for_all_operators"
...     [Function_Hash_Tags]        "LTE 6 operator Ransharing"


variables       ta_e2e_bts_trs_fw
Resource    	${CURDIR}/../resources/common_keywords.robot
Resource    	${CURDIR}/resources/SR001395_Common_Keywords.robot


Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown	Run Keywords	Suite Teardown Postconditions
...		AND		Teardown Oamops


*** Variables ***
${profile}            egate_LTE3065_666_handover

*** Test Cases ***
[1][1.0] LTE3065_R_a_X2_666_handover and Handover TAC check for all operators
	Perform Commissioning       scf_file=${LTE3065_666_handover}    verify_bts_status=False     timeout=400
    Sleep       180
	Get IPv6 Address
	Add IPv6 Interfaces on VM
	Call Setup      lte=${profile}:data   parallel=${False}    verify_attach=${False}    attach=${False}
	Sleep    120
	Verify S1 and X2 link Status for each Operator
    Make LTE call and verify for each operators    6
    [TEARDOWN]    Keyword to Run at end

*** Keywords ***
Get IPv6 Address
	Get MME IP Address     6
	Get LTE-C IP Address    ipV6    6
	Get LTE-U IP Address    ipV6    6
	Get LNADJ IP Address    30      36
	Get SGW IP Address      6

Add IPv6 Interfaces on VM
	Delete Interfaces
	${id}=     Set Variable      0
	Run   sudo ip a a 10.0.1.1/24 dev eth3
	FOR   ${ip}   IN    @{MME_IP_List}
	    ${id}=     Evaluate		${id}+1
		Run    sudo ifconfig eth3:${id} inet6 add ${ip}/116
	END

    FOR   ${ip}   IN    @{SGW_IP_List}
	    ${id}=     Evaluate		${id}+1
		Run    sudo ifconfig eth3:${id} inet6 add ${ip}/116
	END

	FOR   ${ip}   IN    @{LNADJ_IP_List}
	    ${id}=     Evaluate		${id}+1
		Run    sudo ifconfig eth3:${id} inet6 add ${ip}/116
	END

	${len}=    Get Length    ${LTC_IPv6_GW}

	FOR   ${i}   IN RANGE  0   ${len}
	    ${vlan_index}=    Evaluate     ${i}+1
		Run    sudo ip link add link eth3 name eth3.@{vlans}[${vlan_index}] type vlan id @{vlans}[${vlan_index}]
		Run    sudo ip -6 addr add @{LTC_IPv6_GW}[${i}] dev eth3.@{vlans}[${vlan_index}]
		Run	   sudo ip link set dev eth3.@{vlans}[${vlan_index}] up
	END

Verify S1 and X2 link Status for each Operator
	Verify S1 link status		6
	Verify X2 link status    30     36

Make LTE call and verify for each operators
	[Arguments]      ${operators}=1

	FOR  ${index}   IN RANGE   0   ${operators}
	    ${operator}=     Evaluate      ${index}+1
	    ${operator_str}= 	Convert To String	${operator}
		 Traffic capture start           capture_device=l2_wireshark 		alias=operator_${operator_str}
	    Attach LTE UE with operator and send ul dl traffic      ${operator}      ${profile}
	    Stop traffic and detach LTE UE          ${operator}      ${profile}
	    ${pcap_file}=       Traffic capture stop	  alias=operator_${operator_str}
	    ${mme_ip}=     Get from List        ${MME_IP_List}     ${index}
	    ${sgw_ip}=     Get from List        ${SGW_IP_List}     ${index}
	    ${cplaneIp}=   Get from List        ${LTE_C_IP_List}     ${index}
	    ${uplaneIp}=   Get from List        ${LTE_U_IP_List}     ${index}
	    Get IP Version      ${mme_ip}
	    Analyse Pcap      pcap_filename=${pcap_file}      analysis=s1ap_attach_request_${version}     filter_file_name=${traffic_filter_file_name}
	    Analyse Pcap      pcap_filename=${pcap_file}      analysis=s1ap_attach_accept_${version}     filter_file_name=${traffic_filter_file_name}
	    Analyse Pcap      pcap_filename=${pcap_file}      analysis=lte_call_ul_${version}      filter_file_name=${traffic_filter_file_name}
	    Analyse Pcap      pcap_filename=${pcap_file}      analysis=lte_call_dl_${version}      filter_file_name=${traffic_filter_file_name}
	END
	[TEARDOWN]   Run Keyword and Ignore Error     Traffic capture stop	  alias=operator_${operator_str}

Keyword to Run at end
    Call Teardown         lte=${profile}:data
    Run     sudo killall edaemon egate
	Delete Interfaces
