*** Settings ***
Documentation
...		[Author]     		        "Pranitha"
...		[Maintenance]		        "TRS I&V Tools Bangalore Team"
...		[Date] 			            "15:10:2022"
...		[QC_Path]                   "QC_Path in Test Plan"
...		[QC_ID]			            "QC_ID in Test Lab for reporting"
...		[Feature_ID] 		        "CB006540"
...     [Validated_TestLine]        "KVM87-TRSIV-TL001"
...		[Procedure]   		        "CB007158_dualstack"
...     [Precondition]              "ASIL + ABIO with Airphone hardware is required"
...     [Config_Comments]           "Dedicated SeGW and Dedicated PKI"
...     [Function_Hash_Tags]        "SA 6 Operator RAN Sharing, Dual Stack, verify 6 operator call with Airphone"

Variables       ta_e2e_bts_trs_fw
Resource    	${CURDIR}/../resources/common_keywords.robot
#Resource	    ${CURDIR}/resources/SR002750_common_keywords.robot

Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown	Run Keywords	Suite Teardown Postconditions
...		AND		Teardown Oamops

*** Test Cases ***
[1]CB007158-5G-D Dual U Plane Feature support with Maximum configuration
	Perform Recommissioning        type=delta     delta_file=${DualStack_LTE_NR_Ransharing}     timeout=300
    Sleep    180
#    Get IP Address
	Add IPv4 Interfaces on VM
	Add IPv6 Interfaces on VM
    Verify NGAP and S1AP Messages
#	Verify NG link Status      12
#	Verify S1 link Status      12
    Verify Maximum IP Configuration
    Make All Link Down and Check Alarm
    [TEARDOWN]    Keyword to Run at end

*** Keywords ***
Make All Link Down and Check Alarm

    FOR   ${ip}   IN    @{AMF_IP_List_v4}
       Run    sudo ip addr del ${ip} dev eth3
    END

    FOR   ${ip}   IN    @{MME_IP_List_v4}
       Run    sudo ip addr del ${ip} dev eth3
    END

    FOR   ${ip}   IN    @{AMF_IP_List_v6}
       Run    sudo ip -6 addr del ${ip} dev eth3
    END

    FOR   ${ip}   IN    @{MME_IP_List_v6}
       Run    sudo ip -6 addr del ${ip} dev eth3
    END

    Sleep   420

    Verify Alarm     faultid=7305   severity=critical     should_exist=True    occurrences=12
    Verify Alarm     faultid=6202   should_exist=True    occurrences=12

    FOR   ${ip}   IN    @{AMF_IP_List_v4}
       Run    sudo ip addr add ${ip} dev eth3
    END

    FOR   ${ip}   IN    @{MME_IP_List_v4}
       Run    sudo ip addr add ${ip} dev eth3
    END

    FOR   ${ip}   IN    @{AMF_IP_List_v6}
       Run    sudo ip -6 addr add ${ip} dev eth3
    END

    FOR   ${ip}   IN    @{MME_IP_List_v6}
       Run    sudo ip -6 addr add ${ip} dev eth3
    END

    Sleep  420

    Verify Alarm     faultid=7305   should_exist=${False}
    Verify Alarm     faultid=6202   should_exist=${False}



#Get IP Address
#	Get MME IP Address       12
#	Get AMF IP Address       12
#	Get NG-U IP Address      ipV4    6
#	Get NG-U IP Address      ipV6    6
#	Get NG-C IP Address      ipV4    6
#	Get NG-C IP Address      ipV6    6
#	Get LTE-C IP Address     ipV4    6
#	Get LTE-C IP Address     ipV6	 6
#remove above comment

Add IPv4 Interfaces on VM
#	Delete Interfaces

	FOR   ${ip}   IN    @{Simulated_IP}
		Run    sudo ip addr add ${ip} dev eth3
    END

	FOR   ${ip}   IN    @{AMF_IP_List_v4}
		Run    sudo ip addr add ${ip} dev eth3
    END

	FOR   ${ip}   IN    @{MME_IP_List_v4}
		Run    sudo ip addr add ${ip} dev eth3
    END

	FOR   ${ip}   IN    @{DualStack_S1U_IPv4}
		Run    sudo ip addr add ${ip} dev eth3
	END

	FOR   ${ip}   IN    @{DualStack_S11_IP}
		Run    sudo ip addr add ${ip} dev eth3
	END

	${len}=    Get Length    ${NGU_IPv4_GW}

	FOR   ${i}   IN RANGE  0   ${len}
	    ${vlan_index}=    Evaluate     ${i}+1
		Run    sudo ip link add link eth3 name eth3.@{vlans}[${vlan_index}] type vlan id @{vlans}[${vlan_index}]
		Run    sudo ip addr add @{NGU_IPv4_GW}[${i}] dev eth3.@{vlans}[${vlan_index}]
		Run	   sudo ip link set dev eth3.@{vlans}[${vlan_index}] up
	END

	${len}=    Get Length    ${LNU_IPv4_GW}

	FOR   ${i}   IN RANGE  0   ${len}
	    ${vlan_index}=    Evaluate     ${i}+7
		Run    sudo ip link add link eth3 name eth3.@{vlans}[${vlan_index}] type vlan id @{vlans}[${vlan_index}]
		Run    sudo ip addr add @{LNU_IPv4_GW}[${i}] dev eth3.@{vlans}[${vlan_index}]
		Run	   sudo ip link set dev eth3.@{vlans}[${vlan_index}] up
    END

Add IPv6 Interfaces on VM
	FOR   ${ip}   IN    @{AMF_IP_List_v6}
		Run    sudo ip -6 addr add ${ip} dev eth3
	END

	FOR   ${ip}   IN    @{MME_IP_List_v6}
		Run    sudo ip -6 addr add ${ip} dev eth3
    END

	FOR   ${ip}   IN    @{DualStack_S1U_IPv6}
		Run    sudo ip -6 addr add ${ip} dev eth3
	END

	${len}=    Get Length    ${NGU_IPv6_GW}

	FOR   ${i}   IN RANGE  0   ${len}
	    ${vlan_index}=    Evaluate     ${i}+1
		Run    sudo ip link add link eth3 name eth3.@{vlans}[${vlan_index}] type vlan id @{vlans}[${vlan_index}]
		Run    sudo ip -6 addr add @{NGU_IPv6_GW}[${i}] dev eth3.@{vlans}[${vlan_index}]
		Run	   sudo ip link set dev eth3.@{vlans}[${vlan_index}] up
	END

	${len}=    Get Length    ${LNU_IPv6_GW}

	FOR   ${i}   IN RANGE  0   ${len}
	    ${vlan_index}=    Evaluate     ${i}+7
		Run    sudo ip link add link eth3 name eth3.@{vlans}[${vlan_index}] type vlan id @{vlans}[${vlan_index}]
		Run    sudo ip -6 addr add @{LNU_IPv6_GW}[${i}] dev eth3.@{vlans}[${vlan_index}]
		Run	   sudo ip link set dev eth3.@{vlans}[${vlan_index}] up
	END

Verify NGAP and S1AP Messages
    Sleep    180
	Verify Alarm     faultid=7305   severity=critical     should_exist=True    occurrences=12
	Verify Alarm     faultid=6202   should_exist=True    occurrences=12
    Traffic capture start           capture_device=l2_wireshark 		alias=ngap_s1ap
	Call Setup      5g=${profile}:data   parallel=${False}    verify_attach=${False}   attach=${False}
    Sleep    120
    ${pcap_file}=       Traffic capture stop	  alias=ngap_s1ap
    Verify NGAP Messages      ${pcap_file}   12
    Verify S1AP Messages	  ${pcap_file}   12
	Verify Alarm     faultid=7305   should_exist=${False}
	Verify Alarm     faultid=6202   should_exist=${False}
	[TEARDOWN]   Run Keyword and Ignore Error     Traffic capture stop	  alias=ngap_s1ap

Verify NGAP Messages
	[Arguments]        ${pcap_file}    ${operators}=1
	FOR   ${operator}   IN RANGE   0   ${operators}
	     ${ngcplane_ip}=	Get from List     ${NGC_IP_List}       ${operator}
		 ${amf_ip}=		Get from List     ${AMF_IP_List}       ${operator}
#	     Get IP Version      ${amf_ip}
		 Analyse Pcap        pcap_filename=${pcap_file}        analysis=ngap_setup_${version}
	     ...	filter_file_name=${traffic_filter_file_name}
		 Analyse Pcap        pcap_filename=${pcap_file}        analysis=ngap_response_${version}
	    ...	filter_file_name=${traffic_filter_file_name}
	END

Verify S1AP Messages
	[Arguments]        ${pcap_file}    ${operators}=1
	FOR   ${operator}   IN RANGE   0   ${operators}
	     ${lte_cplane_ip}=	Get from List     ${LTE_C_IP_List}       ${operator}
		 ${mme_ip}=		Get from List     ${MME_IP_List}       ${operator}
#	     Get IP Version      ${mme_ip}
		 Analyse Pcap        pcap_filename=${pcap_file}        analysis=s1ap_setup_${version}
	     ...	filter_file_name=${traffic_filter_file_name}
     	 Analyse Pcap        pcap_filename=${pcap_file}        analysis=s1ap_response_${version}
	     ...	filter_file_name=${traffic_filter_file_name}
	END

Verify Maximum IP Configuration
	Perform Recommissioning        type=delta             delta_file=${Max_VLANIF_ASIM}       timeout=300
	Sleep   60
	Perform Recommissioning        type=delta             delta_file=${Max_IPIF_ASIM}         timeout=300
	Sleep   60
	Perform Recommissioning        type=delta             delta_file=${Max_IPRT_ASIM}         timeout=300
	Sleep   30
	Perform Recommissioning        type=delta             delta_file=${Max_IPRTv6_ASIM}       timeout=300
	Sleep   30
	Perform Recommissioning        type=delta             delta_file=${Max_FSTSCH_ASIM}       timeout=300
	Sleep   30

Keyword to Run at end
    Run     sudo killall edaemon egate
#	Delete Interfaces
