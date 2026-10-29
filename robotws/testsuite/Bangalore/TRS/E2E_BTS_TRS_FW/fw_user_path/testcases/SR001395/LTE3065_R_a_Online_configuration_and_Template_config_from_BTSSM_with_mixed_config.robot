*** Settings ***
Documentation
...		[Author]     		        "Nupur"
...		[Maintenance]		        "TRS I&V Tools Bangalore Team"
...		[Date] 			            "12:12:2022"
...		[QC_Path]                   "QC_Path in Test Plan"
...		[QC_ID]			            "QC_ID in Test Lab for reporting"
...		[Feature_ID] 		        "SR001395"
...     [Validated_TestLine]        "ASIM-TL-001"
...		[Procedure]   		        "LTE3065_R_a_Online configuration and Template config from BTSSM with mixed config"
...     [Precondition]              "ASIM+ABIO with AHFIB IPHY hardware is required"
...     [Config_Comments]           "LTE3065_R_a_Online configuration and Template config from BTSSM with mixed config"
...     [Function_Hash_Tags]        "LTE 6 operator Dual Stack Ransharing"


Variables       ta_e2e_bts_trs_fw
Resource    	${CURDIR}/../resources/common_keywords.robot
Resource    	${CURDIR}/resources/SR001395_Common_Keywords.robot


Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown	Run Keywords	Suite Teardown Postconditions
...		AND		Teardown Oamops


*** Variables ***
${profile}            egate_LTE3065_Online_Configuration

*** Test Cases ***
[1][1.0] LTE3065_R_a_Online configuration and Template config from BTSSM with mixed config
	Perform Commissioning       scf_file=${LTE3065_Online_Configuration}    verify_bts_status=False     timeout=400
    Sleep       180
	Get IP Address
	Add IPv4 Interfaces on VM
	Add IPv6 Interfaces on VM
	Call Setup      lte=${profile}:data   parallel=${False}    verify_attach=${False}    attach=${False}
	sleep   60
	Perform Recommissioning		type=delta	  delta_file=${Unlock_MME}      timeout=300
	Sleep   60
	Verify S1 link status		12
	Perform Recommissioning		type=delta	  delta_file=${Lock_IPv6_MME}      timeout=300
	Sleep   60
    Make LTE call and verify for each operators     12
    [TEARDOWN]    Keyword to Run at end

*** Keywords ***
Get IP Address
	Get MME IP Address      12
	Get LTE-C IP Address    ipV4    6
	Get LTE-U IP Address    ipV4    6
	Get LTE-C IP Address    ipV6    6
	Get LTE-U IP Address    ipV6    6
	Get SGW IP Address      12

	${len}=    Get Length    ${MME_IP_List}

	FOR   ${ip}   IN RANGE  0    6
	     Append to List    ${MME_IPv4_List}   @{MME_IP_List}[${ip}]
	END

	FOR   ${ip}   IN RANGE  6    ${len}
	     Append to List    ${MME_IPv6_List}   @{MME_IP_List}[${ip}]
	END

    ${len}=    Get Length    ${SGW_IP_List}

	FOR   ${ip}   IN RANGE  0    6
	     Append to List    ${SGW_IPv4_List}   @{SGW_IP_List}[${ip}]
	END

	FOR   ${ip}   IN RANGE  6    ${len}
	     Append to List    ${SGW_IPv6_List}   @{SGW_IP_List}[${ip}]
	END

Add IPv4 Interfaces on VM
	Delete Interfaces
	${id}=     Set Variable      0
	Run   sudo ip a a 10.0.1.1/24 dev eth3
	FOR   ${ip}   IN    @{MME_IPv4_List}
	   ${id}=     Evaluate		${id}+1
		Run    sudo ifconfig eth3:${id} ${ip} netmask 255.255.255.0 up
	END

    FOR   ${ip}   IN    @{SGW_IPv4_List}
	   ${id}=     Evaluate		${id}+1
		Run    sudo ifconfig eth3:${id} ${ip} netmask 255.255.255.0 up
	END


	${len}=    Get Length    ${LTC_IPv4_GW}

	FOR   ${i}   IN RANGE  0   ${len}
	    ${vlan_index}=    Evaluate     ${i}+1
		Run    sudo ip link add link eth3 name eth3.@{vlans}[${vlan_index}] type vlan id @{vlans}[${vlan_index}]
		Run    sudo ip addr add @{LTC_IPv4_GW}[${i}] dev eth3.@{vlans}[${vlan_index}]
		Run	   sudo ip link set dev eth3.@{vlans}[${vlan_index}] up
	END


Add IPv6 Interfaces on VM
	${id}=     Set Variable      0
	FOR   ${ip}   IN    @{MME_IPv6_List}
	    ${id}=     Evaluate		${id}+1
		Run    sudo ifconfig eth3:${id} inet6 add ${ip}/116
    END

    FOR   ${ip}   IN    @{SGW_IPv6_List}
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

Make LTE call and verify for each operators
	[Arguments]      ${operators}=1

	FOR  ${index}   IN RANGE   0   ${operators}
	    Run Keyword IF      '${index}'=='6'         Perform Recommissioning		type=delta	  delta_file=${Lock_IPv4_MME}      timeout=300
	    ${operator}=     Evaluate      ${index}+1
	    ${operator_str}= 	Convert To String	${operator}
		Traffic capture start           capture_device=l2_wireshark 		alias=operator_${operator_str}
	    Attach LTE UE with operator and send ul dl traffic      ${operator}      ${profile}     1
	    Stop traffic and detach LTE UE          ${operator}      ${profile}
	    ${pcap_file}=       Traffic capture stop	  alias=operator_${operator_str}
	    ${mme_ip}=     Get from List        ${MME_IP_List}     ${index}
	    ${sgw_ip}=     Get from List        ${SGW_IP_List}     ${index}
	    ${cplaneIp}=   Get from List        ${LTE_C_IP_List}     ${index}
	    ${uplaneIp}=   Get from List        ${LTE_U_IP_List}     ${index}
	    Get IP Version      ${mme_ip}
	    Analyse Pcap      pcap_filename=${pcap_file}      analysis=s1ap_attach_request_${version}     filter_file_name=${traffic_filter_file_name}
	    Analyse Pcap      pcap_filename=${pcap_file}      analysis=s1ap_attach_accept_${version}     filter_file_name=${traffic_filter_file_name}
	    Analyse Pcap      pcap_filename=${pcap_file}      analysis=lte_call_ul_${version}     filter_file_name=${traffic_filter_file_name}
	    Analyse Pcap      pcap_filename=${pcap_file}      analysis=lte_call_dl_${version}     filter_file_name=${traffic_filter_file_name}
	END
	[TEARDOWN]   Run Keyword and Ignore Error     Traffic capture stop	  alias=operator_${operator_str}

Keyword to Run at end
    Call Teardown         lte=${profile}:data
    Run     sudo killall edaemon egate
	Delete Interfaces
