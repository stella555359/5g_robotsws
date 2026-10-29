*** Settings ***
Documentation
...		[Author]     	"Priyanka"
...		[Maintenance]	"TRS I & V Tools Bangalore Team"

variables		ta_e2e_bts_trs_fw
#Library			SSHLibrary
#Library			ute_pdu
Library      ${CURDIR}/../resources/Incremental_address.py

*** Variables ***
${enb_root_user}			toor4nsn
${enb_root_passwd}			oZPS0POrRieRtu

*** Keywords ***
Verify Wireshark with ransharing enabled and tranportnwinuse is enabled
	[Arguments]		${pcap_file}
	Verify wireshark for SCTP messages 						${pcap_file}    	${c_plane_ip_o1}    	${mme_o1}
	Verify Wireshark for GTP message                   		${pcap_file}	 	${u_plane_ip_o1}    	${sgw_o1}
	Verify wireshark for SCTP messages IPV6					${pcap_file}    	${c_plane_ipv6_o1}    	${mme_v6_o1}
	Verify Wireshark for GTP message IPV6					${pcap_file}	 	${u_plane_ipv6_o1}    	${sgw_v6_o1}
	FOR	${i}	IN RANGE	2	7
			Verify wireshark for SCTP associations			${pcap_file}    	${c_plane_ip_o${i}}    	${mme_o${i}}
			Verify wireshark for SCTP associations IPV6		${pcap_file}    	${c_plane_ipv6_o${i}}   ${mme_v6_o${i}}
			Verify Wireshark for GTP message                ${pcap_file}	 	${u_plane_ip_o${i}}    	${sgw_o${i}}
			Verify Wireshark for GTP message IPV6			${pcap_file}	 	${u_plane_ipv6_o${i}}   ${sgw_v6_o${i}}
	END
    Verify Calls drop doesnt occur							${pcap_file}		${c_plane_ip_o1}    	${mme_o1}
	Check no s1ap shutdown message occurs					${pcap_file}


Verify Wireshark with ransharing enabled and tranportnwinuse is diabled
	[Arguments]		${pcap_file}
	Verify wireshark for SCTP messages 						${pcap_file}		${c_plane_ip_o1}		${mme_o1}
	Verify Wireshark for GTP message                   		${pcap_file}	 	${u_plane_ip_o1}    	${sgw_o1}
	Verify wireshark for SCTP messages IPV6					${pcap_file}    	${c_plane_ipv6_o1}    	${mme_v6_o1}
	Verify Wireshark for GTP message IPV6					${pcap_file}	 	${u_plane_ipv6_o1}    	${sgw_v6_o1}
#	:FOR	${i}	IN RANGE	2	7
#	\		Verify wireshark for no SCTP messages			${pcap_file}    	${c_plane_ip_o${i}}
#	\		Verify wireshark for no SCTP messages IPV6		${pcap_file}    	${c_plane_ipv6_o${i}}
#	\		Verify Wireshark for no GTP message             ${pcap_file}	 	${u_plane_ip_o${i}}    	${sgw_o${i}}
#	\		Verify Wireshark for no GTP message IPV6		${pcap_file}	 	${u_plane_ipv6_o${i}}   ${sgw_v6_o${i}}
#	Check no s1ap shutdown message occurs		${pcap_file}

Get Ipv4 address
	Download BTS_TRS File from eNB
	Copy File   ${source_file}  ${target_file_1}
	@{ipv4_gateway}=    		Create List
	@{ipv4_application_ip}=		Create List

    ${enb_mPlane_ip_pointer}=   Get Element Text     /tmp/192.168.255.129_scf.xml
    ${m_plane_ip_o1}=		    Get Element Text     /tmp/192.168.255.129_scf.xml

	${index}=	Set Variable	0
	FOR	${i}	IN RANGE	1	7
		${enb_uPlane_ip_pointer}=   Get Element Text     /tmp/192.168.255.129_scf.xml
		${enb_cPlane_ip_pointer}=   Get Element Text     /tmp/192.168.255.129_scf.xml
		${u_plane_ip}=		Get Element Text     /tmp/192.168.255.129_scf.xml
    	${c_plane_ip}=		Get Element Text     /tmp/192.168.255.129_scf.xml
		Set Suite Variable    ${c_plane_ip_o${i}}	${c_plane_ip}
		Set Suite Variable    ${u_plane_ip_o${i}}	${u_plane_ip}
		${index}=		Evaluate	${index}+1
		Append To List      ${ipv4_application_ip}     ${c_plane_ip_o${i}}
		Append To List      ${ipv4_application_ip}     ${u_plane_ip_o${i}}
	END
    Log To Console		${ipv4_application_ip}
	@{ipv4_gateway}=   Get Elements Texts    ${target_file_1}

	Set Suite Variable		${ipv4_gateway}				${ipv4_gateway}
	Set Suite Variable		${ipv4_application_ip}		${ipv4_application_ip}
	Set Suite Variable    ${m_plane_ip_o1}	 ${m_plane_ip_o1}
Check no s1ap shutdown message occurs
    [Arguments]     ${pcap_file}
    ${output}=  Get no.of packets from wireshark         ${pcap_file}		s1ap.Reset_element
    Should Be Equal As Integers     ${output}   0

    ${output}=  Get no.of packets from wireshark         ${pcap_file}  		s1ap.ResetAcknowledge_element
    Should Be Equal As Integers     ${output}   0

Get IPv6 address
	Download BTS_TRS File from eNB
	Copy File   ${source_file}  ${target_file_1}
	@{ipv6_gateway}=    Create List
	@{ipv6_application_ip}=    Create List

	${index}=	Set Variable	0
	FOR	${i}	IN RANGE	1	7
	Log To Console		${ipv6_application_ip}

	@{ipv6_gateway}=   Get Elements Texts    ${target_file_1}
	Remove From List		${ipv6_gateway}		0

	Set Suite Variable		${ipv6_gateway}				${ipv6_gateway}
	Set Suite Variable		${ipv6_application_ip}		${ipv6_application_ip}
Add ipv6 VLANs on VM
    [Arguments]     ${ip}   ${val}
    Run     sudo ifconfig eth3 inet6 add fc00::1/116
    ${number1}   Evaluate    int(${val})
#    ${ip1}=  Encode String To Bytes       ${ip}   UTF-8
    ${output}=  FunIncrementIp      ${ip}   ${number1}
    ${ipv6_addresses}=      Get_IP_Array        ${output}
    FOR    ${i}    IN RANGE    6
           Run     sudo ifconfig eth3.@{tl.vlan_ids}[${i}] inet6 add @{ipv6_addresses}[${i}]/126
    END
Add ipv6 VLAN's on VM
    Run     sudo ifconfig eth3 inet6 add fc00::1/116
    @{ipv6_addresses}=      Create List     fc00::3:6/126       fc00::3:a/126       fc00::3:e/126       fc00::3:12/126      fc00::3:16/126

    FOR    ${i}    IN RANGE    6
           Continue For Loop If    ${i}==3
           Run Keyword If      ${i}<3      Run     sudo ifconfig eth3.@{tl.vlan_ids}[${i}] inet6 add @{ipv6_addresses}[${i}]
    END
Create ipv4 list for simulated MME and SGW
    @{ipv4_address}=    Create List
    FOR    ${index}     IN RANGE    20    56
           ${ip_val}=      Set Variable    10.0.1.${index}
           Append To List      ${ipv4_address}     ${ip_val}
    END
    Log To console      ${ipv4_address}
    Set Suite Variable          @{ipv4_address}     @{ipv4_address}

Create ipv6 list for simulated MME and SGW
    @{ipv6_address}=    Create List
    FOR    ${index}     IN RANGE    20    56
           ${ip_val}=      Set Variable    fc00::${index}
           Append To List      ${ipv6_address}     ${ip_val}
    END
    Log To console      ${ipv6_address}
    Set Suite Variable          @{ipv6_address}     @{ipv6_address}
BringUp Logical Interfaces for Simulated eNB, S-Gws, MMEs with ipv4
    Create ipv4 list for simulated MME and SGW
#   @{interfaces}=      Create List     1   2   3   4   5   6   7   8   9   10  11  12  13  14
#   ${length}=    Get Length    ${interfaces}
    FOR    ${i}    IN RANGE        0       36
           ${value}=       Evaluate    ${i}+1
           Run         sudo ifconfig eth3:${value} @{ipv4_address}[${i}] netmask ${netmask} up
    END

BringUp Logical Interfaces for Simulated eNB, S-Gws, MMEs with ipv6
    Create ipv6 list for simulated MME and SGW
    ${length}=    Get Length    ${ipv6_address}
    FOR    ${i}    IN RANGE        ${length}
           Run         sudo ifconfig eth3 inet6 add @{ipv6_address}[${i}]/116
           Run         sudo ip link set dev eth3 up
    END
Ping to IPv4 Gateway/Application IP should be sucessful
	Remove Duplicates				${ipv4_gateway}
	Remove Duplicates				${ipv4_application_ip}
	FOR	${i}	IN RANGE	0	6
         ${output}=  Run  ping -I @{ipv4_gateway}[${i}] @{ipv4_application_ip}[${i}] -c 5
    	  Should contain  	${output}  	5 packets transmitted, 5 received
    END
Ping to IPv6 Gateway/Application IP should be sucessful
	Remove Duplicates				${ipv6_gateway}
	Remove Duplicates				${ipv6_application_ip}
	FOR	${i}	IN RANGE	0	6
			${output}=  Run  ping6 -I @{ipv6_gateway}[${i}] @{ipv6_application_ip}[${i}] -c 5
    		Should contain      ${output}   5 packets transmitted, 5 received
    END
Verify Wireshark Messages of IPv6 Address
    [Arguments]     ${polling_pcap}     ${filter}        ${enb_addr}        ${sgw_address}      ${no_of_sgw}
#    ${ip1}=  Encode String To Bytes       ${sgw_address}   UTF-8
    ${number1}   Evaluate    int(${no_of_sgw})
    ${ipList}=  FunIncrementIp      ${sgw_address}   ${number1}
    Log     ${ipList}

    ${length}=    Get Length    ${ipList}
    FOR    ${i}    IN RANGE        ${length}
       ${output}=  Run     tshark -r ${polling_pcap} -Y "${filter} && ipv6.src==${enb_addr} && ipv6.dst==@{ipList}[${i}]" 2>/dev/null
       Should Not Be Empty    ${output}
       ${output}=  Run     tshark -r ${polling_pcap} -Y "${filter} && ipv6.src==@{ipList}[${i}] && ipv6.dst==${enb_addr}" 2>/dev/null
       Should Not Be Empty   ${output}
    END
Verify Wireshark Messages of IPv4 Address
    [Arguments]     ${file2}     ${filter}       ${number_of_sgw}        ${enb_addr}         ${sgw_addr}
    @{list}=        Split String            ${sgw_addr}    separator=.
    ${list_elements} =    Split String    ${list[0]}
    ${list_elements1} =    Split String    ${list[1]}
    ${list_elements2} =    Split String    ${list[2]}
    ${list_elements3} =    Split String    ${list[3]}
    ${a}=    Set Variable   ${list_elements[0]}
    ${b}=    Set Variable   ${list_elements1[0]}
    ${c}=    Set Variable   ${list_elements2[0]}
    ${d}=    Set Variable   ${list_elements3[0]}
    ${start_address}=     Set Variable   ${d}
    ${addr}=    Set Variable    ${a}.${b}.${c}.${d}
    FOR    ${i}    IN RANGE        ${number_of_sgw}
       ${addr}=    Set Variable    ${a}.${b}.${c}.${d}
       ${output}=      Run     tshark -r ${file2} -Y "${filter} && ip.src==${enb_addr} && ip.dst==${addr}" | wc -l
#    \   ${output}=  Run     tshark -r unsupervised_gtp.pcap
       Should Not Be Empty   ${output}
       ${output}=      Run     tshark -r ${file2} -Y "${filter} && ip.src==${addr} && ip.dst==${enb_addr}" | wc -l
#    \   ${output}=  Run     tshark -r unsupervised_gtp_1.pcap
       Should Not Be Empty   ${output}
       ${d}=   Evaluate    ${d}+1
       ${c}=   Run Keyword If     '${d}'=='256'      Evaluate    ${c}+1
       ...     ELSE    Set Variable    ${c}
       ${d}=   Run Keyword If     '${d}'=='256'      Set Variable     ${start_address}
       ...     ELSE    Set Variable    ${d}
    END
Create and Bring Logical Interfaces UP IPV6
    [Arguments]     ${sgw_address}      ${no_of_sgw}
#    ${ip1}=  Encode String To Bytes       ${sgw_address}   UTF-8
    ${number1}   Evaluate    int(${no_of_sgw})
    ${output}=  FunIncrementIp      ${sgw_address}   ${number1}
    Log     ${output}

    ${length}=    Get Length    ${output}
    FOR    ${i}    IN RANGE        ${length}
           Run         sudo ifconfig eth3.200 inet6 add ${output}[${i}]/116
           Run         sudo ip link set dev eth3.200 up
    END

Create and Bring Logical Interfaces UP IPV4
    [Arguments]     ${sgw_address}      ${no_of_sgw}
    ${number1}   Evaluate    int(${no_of_sgw})
    ${output}=  FunIncrementIp      ${sgw_address}   ${number1}
    Log     ${output}

    ${length}=    Get Length    ${output}
    FOR    ${i}    IN RANGE        ${length}
           Run         sudo ifconfig eth3.200 add ${output}[${i}]
           Run         sudo ip link set dev eth3.200 up
    END
Wireshark verification for IPV4
    [Arguments]    ${file}    ${sgw_address}    ${output}
   ${ip1}=  Encode String To Bytes       ${sgw_address}   UTF-8
    ${number1}   Evaluate    int(${no_of_sgw})
    ${output}=  FunIncrementIp      ${sgw_address}   ${number1}
    Log     ${output}

    ${length}=    Get Length    ${output}
	${length}=		Evaluate	${length}-3
    FOR    ${i}    IN RANGE        ${length}
	 		${request}=		Run  tshark -r ${file} -Y "ip.dst==@{output}[${i}] && ip.src == 10.0.3.210 && gtp.message == 0x01" | wc -l 2>/dev/null
    		Should Not Be Equal		${request}		0
	      ${length}=		Run  tshark -r ${file} -Y "ip.src==@{output}[${i}] && ip.dst == 10.0.3.210 && gtp.message == 0x02" | wc -l 2>/dev/null
           Should Not Be Equal		${length}		0
    END
Wireshark verification for IPV4 plain
    [Arguments]     ${sgw_address}      ${no_of_sgw}		${file}
#   ${ip1}=  Encode String To Bytes       ${sgw_address}   UTF-8
    ${number1}   Evaluate    int(${no_of_sgw})
    ${output}=  FunIncrementIp      ${sgw_address}   ${number1}
    Log     ${output}

    ${length}=    Get Length    ${output}
	${length}=		Evaluate	${length}-3
    FOR    ${i}    IN RANGE        ${length}
	 		${request}=		Run  tshark -r ${file} -Y "ip.dst==@{output}[${i}] && ip.src == 10.0.1.2 && gtp.message == 0x01" | wc -l 2>/dev/null
    		Should Not Be Equal		${request}		0
	       ${length}=		Run  tshark -r ${file} -Y "ip.src==@{output}[${i}] && ip.dst == 10.0.1.2 && gtp.message == 0x02" | wc -l 2>/dev/null
           Should Not Be Equal		${length}		0
    END
Wireshark verification for IPV6
    [Arguments]     ${sgw_address}      ${no_of_sgw}		${file}
#    ${ip1}=  Encode String To Bytes       ${sgw_address}   UTF-8
    ${number1}   Evaluate    int(${no_of_sgw})
    ${output}=  FunIncrementIp      ${sgw_address}   ${number1}
    Log     ${output}

    ${length}=    Get Length    ${output}
	${length}=		Evaluate	${length}-3
    FOR    ${i}    IN RANGE        ${length}
	 		${request}=		Run  tshark -r ${file} -Y "ipv6.dst==@{output}[${i}] && ipv6.src == fc00::3:7 && gtp.message == 0x01" | wc -l 2>/dev/null
    		Should Not Be Equal		${request}		0
	        ${length}=		Run  tshark -r ${file} -Y "ipv6.src==@{output}[${i}] && ipv6.dst == fc00::3:7 && gtp.message == 0x02" | wc -l 2>/dev/null
            Should Not Be Equal		${length}		0
    END

