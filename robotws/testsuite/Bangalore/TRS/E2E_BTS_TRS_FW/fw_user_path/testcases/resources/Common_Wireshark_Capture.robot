*** Settings ***
Documentation
...		[Author]     	"Nandini R"
...		[Maintenance]	"TRS I & V Tools Bangalore Team"

variables		ta_e2e_bts_trs_fw
Resource		taf/rfrl/trs_e2e_fw/setup/framework.robot
Library			SSHLibrary
# Library			ute_pdu

*** Variables ***
${enb_root_user}			toor4nsn
${enb_root_passwd}			oZPS0POrRieRtu

*** Keywords ***
Verify wireshark for SCTP associations
	[Arguments]		${pcap_file}    ${c_plane_ip}   ${mme_ip}
	${output}=	Run  tshark -r ${pcap_file} -Y "sctp.chunk_type==1 && ip.src == ${c_plane_ip} && ip.dst == ${mme_ip}" 2>/tmp/stderr.txt
	Should Not Be Empty   ${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "sctp.chunk_type==2 && ip.src == ${mme_ip} && ip.dst == ${c_plane_ip}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "sctp.chunk_type==10 && ip.src == ${c_plane_ip} && ip.dst == ${mme_ip}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "sctp.chunk_type==11 && ip.src == ${mme_ip} && ip.dst == ${c_plane_ip}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "s1ap.S1SetupRequest_element && ip.src == ${c_plane_ip} && ip.dst==${mme_ip}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "s1ap.S1SetupResponse_element && ip.src==${mme_ip} && ip.dst == ${c_plane_ip}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "sctp.ack && ip.src == ${mme_ip} && ip.dst == ${c_plane_ip}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "sctp.ack && ip.src == ${c_plane_ip} && ip.dst == ${mme_ip}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "sctp.chunk_type==4 && ip.src == ${mme_ip} && ip.dst == ${c_plane_ip}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "sctp.chunk_type==4 && ip.dst == ${mme_ip} && ip.src == ${c_plane_ip}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "sctp.chunk_type==5 && ip.dst == ${mme_ip} && ip.src == ${c_plane_ip}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "sctp.chunk_type==5 && ip.src == ${mme_ip} && ip.dst == ${c_plane_ip}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}


Verify wireshark for no SCTP messages
	[Arguments]		${pcap_file}    ${mme_ip}
	${output}=	Run  tshark -r ${pcap_file} -Y "sctp && ip.addr == ${mme_ip}" 2>/tmp/stderr.txt
	Should Be Empty   ${output}


Verify wireshark for SCTP messages
	[Arguments]		${pcap_file}    ${c_plane_ip_1}		${mme_ip}
	${output}=	Run  tshark -r ${pcap_file} -Y "sctp.chunk_type==4 && ip.src == ${mme_ip} && ip.dst == ${c_plane_ip_1}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "sctp.chunk_type==4 && ip.dst == ${mme_ip} && ip.src == ${c_plane_ip_1}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "sctp.chunk_type==5 && ip.dst == ${mme_ip} && ip.src == ${c_plane_ip_1}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "sctp.chunk_type==5 && ip.src == ${mme_ip} && ip.dst == ${c_plane_ip_1}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}



Verify wireshark for X2AP messages
	[Arguments]		${pcap_file}    ${c_plane_ip}   ${eNB2_ip}
	${output}=		Run  tshark -r ${pcap_file} -Y "x2ap.X2AP_PDU == 0 && ip.src == ${c_plane_ip} && ip.dst == ${eNB2_ip}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}

#	${output}=		Run  tshark -r ${pcap_file} -Y "x2ap.X2AP_PDU == 0 && ip.dst == ${c_plane_ip} && ip.src == ${eNB2_ip}" 2>/tmp/stderr.txt
#	Should Not Be Empty		${output}

#	${output}=		Run  tshark -r ${pcap_file} -Y "x2ap.X2AP_PDU == 1 && ip.src == ${c_plane_ip} && ip.dst == ${eNB2_ip}" 2>/tmp/stderr.txt
#	Should Not Be Empty		${output}

	${output}=		Run  tshark -r ${pcap_file} -Y "x2ap.X2AP_PDU == 1 && ip.dst == ${c_plane_ip} && ip.src == ${eNB2_ip}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}


Verify Wireshark for GTP message
	[Arguments]		${pcap_file}    ${u_plane_ip}   ${sgw_ip}
	${output}=	Run  tshark -r ${pcap_file} -Y "gtp.message==0x01 && ip.src == ${u_plane_ip} && ip.dst == ${sgw_ip}" 2>/tmp/stderr.txt
	Should Not Be Empty   ${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "gtp.message==0x02 && ip.dst == ${u_plane_ip} && ip.src == ${sgw_ip}" 2>/tmp/stderr.txt
	Should Not Be Empty   ${output}


Verify Wireshark for no GTP message
	[Arguments]		${pcap_file}    ${u_plane_ip}   ${sgw_ip}
	${output}=	Run  tshark -r ${pcap_file} -Y "gtp.message==0x01 && ip.src == ${u_plane_ip} && ip.dst == ${sgw_ip}" 2>/tmp/stderr.txt
	Should Be Empty   ${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "gtp.message==0x02 && ip.dst == ${u_plane_ip} && ip.src == ${sgw_ip}" 2>/tmp/stderr.txt
	Should Be Empty   ${output}


Verify s1 reset and shutdown message
	[Arguments]		${pcap_file}    ${c_plane_ip}    ${mme_ip}
	${output}=		 Run  tshark -r ${pcap_file} -Y "s1ap.Reset_element && ip.src == ${c_plane_ip} && ip.dst == ${mme_ip} " 2>/tmp/stderr.txt
	Should Not Be Empty   ${output}

	${output}=		 Run  tshark -r ${pcap_file} -Y "s1ap.ResetAcknowledge_element && ip.src == ${mme_ip}
	...    && ip.dst == ${c_plane_ip} " 2>/tmp/stderr.txt
	Should Not Be Empty   ${output}

	${output}=		 Run  tshark -r ${pcap_file} -Y "sctp.chunk_type==7 && ip.src == ${c_plane_ip} && ip.dst == ${mme_ip} " 2>/tmp/stderr.txt
	Should Not Be Empty   ${output}

	${output}=		 Run  tshark -r ${pcap_file} -Y "sctp.chunk_type==8 && ip.src == ${mme_ip} && ip.dst == ${c_plane_ip} " 2>/tmp/stderr.txt
	Should Not Be Empty   ${output}

	${output}=		 Run  tshark -r ${pcap_file} -Y "sctp.chunk_type==14 && ip.src == ${c_plane_ip} && ip.dst == ${mme_ip} " 2>/tmp/stderr.txt
	Should Not Be Empty   ${output}


Verify whether ESPPackets have been captured
	[Arguments]		${pcap_file}    ${uPlane_ip}	${cPlane_ip}	${mPlane_ip}
	${output}= 		Run  tshark -r ${pcap_file} -Y "esp && ip.src == ${uPlane_ip}"
	Should Not Be Empty  	 ${output}

	${output}= 		Run  tshark -r ${pcap_file} -Y "esp && ip.src == ${cPlane_ip}"
	Should Not Be Empty  	 ${output}

	${output}= 		Run  tshark -r ${pcap_file} -Y "esp && ip.src == ${mPlane_ip}"
	Should Not Be Empty  	 ${output}
Verify wireshark for SCTP messages IPV6
	[Arguments]		${pcap_file}    ${c_plane_ip}   ${mme_ip}
	${output}=	Run  tshark -r ${pcap_file} -Y "sctp.chunk_type==4 && ipv6.src == ${mme_ip} && ipv6.dst == ${c_plane_ip}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "sctp.chunk_type==4 && ipv6.dst == ${mme_ip} && ipv6.src == ${c_plane_ip}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "sctp.chunk_type==5 && ipv6.dst == ${mme_ip} && ipv6.src == ${c_plane_ip}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "sctp.chunk_type==5 && ipv6.src == ${mme_ip} && ipv6.dst == ${c_plane_ip}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}

Verify Wireshark for GTP message IPV6
	[Arguments]		${pcap_file}    ${u_plane_ipv6}   ${sgw_ipv6}
	${output}=	Run  tshark -r ${pcap_file} -Y "gtp.message==0x01 && ipv6.src == ${u_plane_ipv6} && ipv6.dst == ${sgw_ipv6}" 2>/tmp/stderr.txt
	Should Not Be Empty   ${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "gtp.message==0x02 && ipv6.dst == ${u_plane_ipv6} && ipv6.src == ${sgw_ipv6}" 2>/tmp/stderr.txt
	Should Not Be Empty   ${output}

Verify wireshark for no SCTP messages IPV6
	[Arguments]		${pcap_file}    ${c_plane_ip}
	${output}=	Run  tshark -r ${pcap_file} -Y "sctp && ipv6.src == ${c_plane_ip}" 2>/tmp/stderr.txt
	Should Be Empty   ${output}

Verify Wireshark for no GTP message IPV6
	[Arguments]		${pcap_file}    ${u_plane_ipv6}   ${sgw_ipv6}
	${output}=	Run  tshark -r ${pcap_file} -Y "gtp.message==0x01 && ipv6.src == ${u_plane_ipv6} && ipv6.dst == ${sgw_ipv6}" 2>/tmp/stderr.txt
	Should Be Empty   ${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "gtp.message==0x02 && ipv6.dst == ${u_plane_ipv6} && ipv6.src == ${sgw_ipv6}" 2>/tmp/stderr.txt
	Should Be Empty   ${output}

Verify wireshark for SCTP associations IPV6
	[Arguments]		${pcap_file}    ${c_plane_ipv6}   ${mme_ipv6}
	${output}=	Run  tshark -r ${pcap_file} -Y "sctp.chunk_type==1 && ipv6.src == ${c_plane_ipv6} && ipv6.dst == ${mme_ipv6}" 2>/tmp/stderr.txt
	Should Not Be Empty   ${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "sctp.chunk_type==2 && ipv6.src == ${mme_ipv6} && ipv6.dst == ${c_plane_ipv6}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "sctp.chunk_type==10 && ipv6.src == ${c_plane_ipv6} && ipv6.dst == ${mme_ipv6}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "sctp.chunk_type==11 && ipv6.src == ${mme_ipv6} && ipv6.dst == ${c_plane_ipv6}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "s1ap.S1SetupRequest_element && ipv6.src == ${c_plane_ipv6} &&
	...     ipv6.dst==${mme_ipv6}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "s1ap.S1SetupResponse_element && ipv6.src==${mme_ipv6} &&
	...    ipv6.dst == ${c_plane_ipv6}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "sctp.ack && ipv6.src == ${mme_ipv6} && ipv6.dst == ${c_plane_ipv6}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "sctp.ack && ipv6.src == ${c_plane_ipv6} && ipv6.dst == ${mme_ipv6}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "sctp.chunk_type==4 && ipv6.src == ${mme_ipv6} && ipv6.dst == ${c_plane_ipv6}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "sctp.chunk_type==4 && ipv6.dst == ${mme_ipv6} && ipv6.src == ${c_plane_ipv6}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "sctp.chunk_type==5 && ipv6.dst == ${mme_ipv6} && ipv6.src == ${c_plane_ipv6}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "sctp.chunk_type==5 && ipv6.src == ${mme_ipv6} && ipv6.dst == ${c_plane_ipv6}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output
