*** Settings ***
Documentation
...		[Author]     	"Vivin"
...		[Maintenance]	"TRS I & V Tools Bangalore Team"

Variables		ta_e2e_bts_trs_fw
Resource		taf/rfrl/trs_e2e_fw/setup/framework.robot
Library			SSHLibrary

*** Keywords ***
Initial Configuration
	Bring Up Interfaces on VM
	Setup Oamops on Chained Enb		${LMP_IP}	${Enb2_Plain_mplane_IP}

Initial Configuration Teardown
	Bring Down Interfaces on VM
	Teardown Oamops on Chained Enb

Bring Up Interfaces on VM
	Run        sudo ip link add link eth3 name eth3.@{tl.vlan_ids}[0] type vlan id @{tl.vlan_ids}[0]
	Run        sudo ip addr add 10.0.3.209/29 brd 10.0.3.215 dev eth3.@{tl.vlan_ids}[0]
	Run        sudo ip link set dev eth3.@{tl.vlan_ids}[0] up
	Run        sudo ifconfig eth3.@{tl.vlan_ids}[0] inet6 add fc00::3:4/125

	Run        sudo ip link add link eth3 name eth3.@{tl.vlan_ids}[1] type vlan id @{tl.vlan_ids}[1]
	Run        sudo ip addr add 10.0.3.217/29 brd 10.0.3.223 dev eth3.@{tl.vlan_ids}[1]
	Run        sudo ip link set dev eth3.@{tl.vlan_ids}[1] up
	Run        sudo ifconfig eth3.@{tl.vlan_ids}[1] inet6 add fc00::3:c/125

	Run        sudo ip link add link eth3 name eth3.@{tl.vlan_ids}[2] type vlan id @{tl.vlan_ids}[2]
	Run        sudo ip addr add 10.0.3.225/29 brd 10.0.3.231 dev eth3.@{tl.vlan_ids}[2]
	Run        sudo ip link set dev eth3.@{tl.vlan_ids}[2] up
	Run        sudo ifconfig eth3.@{tl.vlan_ids}[2] inet6 add fc00::3:14/125

	Run        sudo ip link add link eth3 name eth3.@{tl.vlan_ids}[3] type vlan id @{tl.vlan_ids}[3]
	Run        sudo ip addr add 10.0.3.233/29 brd 10.0.3.239 dev eth3.@{tl.vlan_ids}[3]
	Run        sudo ip link set dev eth3.@{tl.vlan_ids}[3] up
	Run        sudo ifconfig eth3.@{tl.vlan_ids}[3] inet6 add fc00::3:1c/125

Bring Down Interfaces on VM
	Run		sudo ip link delete eth3.@{tl.vlan_ids}[0]
	Run		sudo ip link delete eth3.@{tl.vlan_ids}[1]
	Run		sudo ip link delete eth3.@{tl.vlan_ids}[2]
	Run		sudo ip link delete eth3.@{tl.vlan_ids}[3]

Add routes to Virtual Interface IP's in VM
	Run		sudo ip r add 10.0.3.242/32 via 10.0.3.211
	Run		sudo ip r add 10.0.3.246/32 via 10.0.3.219
	Run		sudo ip r add 10.0.3.250/32 via 10.0.3.227
	Run		sudo ip r add 10.0.3.254/32 via 10.0.3.235

Setup Oamops on Chained Enb
	[Arguments]		${Enb1_LMP_Mplane_IP}	${Enb2_mplane_IP}
	Setup Oamops		bts_host=${Enb1_LMP_Mplane_IP}	alias=Enb1
	Setup Oamops		bts_host=${Enb2_mplane_IP}	alias=Enb2

Teardown Oamops on Chained Enb
	Teardown Oamops		alias=Enb1
	Teardown Oamops		alias=Enb2


Perform Vlan Configuration in Primary Setup
    [Arguments]     ${Comm_file}    ${alias}=default
	Update VLAN ID's of Commissioning File		${scf_dir}		${Comm_file}
    Perform Commissioning       scf_file=${Comm_file}       verify_bts_status=False     alias=${alias}


Perform IPv6 Vlan Configuration in Primary Setup
	[Arguments]		${Comm_file}
	Update VLAN ID's of Commissioning File		${Comm_file}
	Perform Commissioning		scf_file=${Comm_file}		verify_bts_status=False

	Run        sudo ip link add link eth3 name eth3.@{tl.vlan_ids}[0] type vlan id @{tl.vlan_ids}[0]
	Run        sudo ip addr add 10.0.3.209/29 brd 10.0.3.215 dev eth3.@{tl.vlan_ids}[0]
	Run        sudo ip link set dev eth3.@{tl.vlan_ids}[0] up
	Run        sudo ifconfig eth3.@{tl.vlan_ids}[0] inet6 add fc00::3:6/126

	Run        sudo ip link add link eth3 name eth3.@{tl.vlan_ids}[1] type vlan id @{tl.vlan_ids}[1]
	Run        sudo ip addr add 10.0.3.217/29 brd 10.0.3.223 dev eth3.@{tl.vlan_ids}[1]
	Run        sudo ip link set dev eth3.@{tl.vlan_ids}[1] up
	Run        sudo ifconfig eth3.@{tl.vlan_ids}[1] inet6 add fc00::3:a/126

	Run        sudo ip link add link eth3 name eth3.@{tl.vlan_ids}[2] type vlan id @{tl.vlan_ids}[2]
	Run        sudo ip addr add 10.0.3.225/29 brd 10.0.3.231 dev eth3.@{tl.vlan_ids}[2]
	Run        sudo ip link set dev eth3.@{tl.vlan_ids}[2] up
	Run        sudo ifconfig eth3.@{tl.vlan_ids}[2] inet6 add fc00::3:e/126

	Run        sudo ip link add link eth3 name eth3.@{tl.vlan_ids}[3] type vlan id @{tl.vlan_ids}[3]
	Run        sudo ip addr add 10.0.3.233/29 brd 10.0.3.239 dev eth3.@{tl.vlan_ids}[3]
	Run        sudo ip link set dev eth3.@{tl.vlan_ids}[3] up
	Run        sudo ifconfig eth3.@{tl.vlan_ids}[3] inet6 add fc00::3:12/126



Verify Parameter has been updated in Admin with modified value
	[Arguments]		${Param_path}		${Param_name} 		${Changed_value}	${alias}=default
	${Parameter}=		Get Parameter	param_path=${Param_path}:${Param_name}	alias=${alias}
    Should Be Equal		${Parameter}         ${Changed_value}

Verify whether Parameter is persistent after ENB reboot
	[Arguments]		${Param_path_name}		${Expected_value}	${alias}=default
	${Parameter}=		Get Parameter	param_path=${Param_path_name}	alias=${alias}
    Should Be Equal		${Parameter}         ${Expected_value}

Verify wireshark for SCTP messages of enB
	[Arguments]		${pcap_file}    ${c_plane_ip_1}	   ${mme_ip}
	${output}=	Run  tshark -r ${pcap_file} -Y "sctp.chunk_type==4 && ip.src == ${mme_ip} && ip.dst == ${c_plane_ip_1}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}
	#try using analse capture from common framrwork
	${output}=	Run  tshark -r ${pcap_file} -Y "sctp.chunk_type==4 && ip.dst == ${mme_ip} && ip.src == ${c_plane_ip_1}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "sctp.chunk_type==5 && ip.dst == ${mme_ip} && ip.src == ${c_plane_ip_1}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "sctp.chunk_type==5 && ip.src == ${mme_ip} && ip.dst == ${c_plane_ip_1}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}


Verify wireshark for encrypted SCTP messages of both enB
	[Arguments]		${pcap_file}    ${c_plane_ip_1}		${c_plane_ip_2}	   ${mme_ip}	${tunnel_ip}
	${output}=	Run  tshark -r ${pcap_file} -Y "sctp.chunk_type==4 && ip.src == ${mme_ip} && ip.dst == ${c_plane_ip_1}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "sctp.chunk_type==4 && ip.dst == ${mme_ip} && ip.src == ${c_plane_ip_1}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "sctp.chunk_type==5 && ip.dst == ${mme_ip} && ip.src == ${c_plane_ip_1}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "sctp.chunk_type==5 && ip.src == ${mme_ip} && ip.dst == ${c_plane_ip_1}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "esp && ip.src == ${tunnel_ip} && ip.dst == ${c_plane_ip_1}" 2>/tmp/stderr.txt
	Should Be Empty		${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "esp && ip.addr == ${tunnel_ip} && ip.addr == ${c_plane_ip_2}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "sctp && ip.addr == ${mme_ip} && ip.addr == ${c_plane_ip_2}" 2>/tmp/stderr.txt
	Should Be Empty		${output}


Verify wireshark for SCTP messages on primary enB and no SCTP messages on secondary enB
	[Arguments]		${pcap_file}    ${c_plane_ip_1}		${c_plane_ip_2}	   ${mme_ip}	${tunnel_ip}
	${output}=	Run  tshark -r ${pcap_file} -Y "sctp.chunk_type==4 && ip.src == ${mme_ip} && ip.dst == ${c_plane_ip_1}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "sctp.chunk_type==4 && ip.dst == ${mme_ip} && ip.src == ${c_plane_ip_1}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "sctp.chunk_type==5 && ip.dst == ${mme_ip} && ip.src == ${c_plane_ip_1}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "sctp.chunk_type==5 && ip.src == ${mme_ip} && ip.dst == ${c_plane_ip_1}" 2>/tmp/stderr.txt
	Should Not Be Empty		${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "esp && ip.addr == ${tunnel_ip} && ip.addr == ${c_plane_ip_2}" 2>/tmp/stderr.txt
	Should Be Empty		${output}

	${output}=	Run  tshark -r ${pcap_file} -Y "sctp && ip.addr == ${mme_ip} && ip.addr == ${c_plane_ip_2}" 2>/tmp/stderr.txt
	Should Be Empty		${output}


Verify Wireshark for GTP message on both enB
	[Arguments]		${pcap_file}    ${u_plane_ip_1}	   ${ue_ip_1}	${u_plane_ip_2}		${ue_ip_2}
	${output}=  Run  tshark -r ${pcap_file} -Y "gtp && ip.src==${u_plane_ip_1} && ip.src==${ue_ip_1} " 2>/tmp/stderr.txt
    Should Not Be Empty   ${output}

	${output}=  Run  tshark -r ${pcap_file} -Y "gtp && ip.src==${u_plane_ip_2} && ip.src==${ue_ip_2} " 2>/tmp/stderr.txt
    Should Not Be Empty   ${output}


Verify wireshark for encrypted GTP message of both enB
	[Arguments]		${pcap_file}    ${u_plane_ip_1}	   ${ue_ip_1}	${u_plane_ip_2}		${ue_ip_2}		${remote_tunnel_ip}
	${output}=  Run  tshark -r ${pcap_file} -Y "gtp && ip.src==${u_plane_ip_1} && ip.src==${ue_ip_1} " 2>/tmp/stderr.txt
    Should Not Be Empty   ${output}

	${output}=  Run  tshark -r ${pcap_file} -Y "esp && ip.src==${u_plane_ip_1} && ip.src==${ue_ip_1} " 2>/tmp/stderr.txt
    Should Be Empty   ${output}

	${output}=  Run  tshark -r ${pcap_file} -Y "gtp && ip.src==${u_plane_ip_2} && ip.src==${ue_ip_2} " 2>/tmp/stderr.txt
    Should Be Empty   ${output}

	${output}=  Run  tshark -r ${pcap_file} -Y "esp && ip.src==${u_plane_ip_2} && ip.dst == ${remote_tunnel_ip}" 2>/tmp/stderr.txt
    Should Not Be Empty   ${output}


Verify Wireshark for GTP message on primary enB and no GTP messages on secondary enB
	[Arguments]		${pcap_file}    ${u_plane_ip_1}	   ${ue_ip_1}	${u_plane_ip_2}		${ue_ip_2}		${remote_tunnel_ip}
	${output}=  Run  tshark -r ${pcap_file} -Y "gtp && ip.src==${u_plane_ip_1} && ip.src==${ue_ip_1} " 2>/tmp/stderr.txt
    Should Not Be Empty   ${output}

	${output}=  Run  tshark -r ${pcap_file} -Y "gtp && ip.src==${u_plane_ip_2} && ip.src==${ue_ip_2} " 2>/tmp/stderr.txt
    Should Be Empty   ${output}

	${output}=  Run  tshark -r ${pcap_file} -Y "esp && ip.src==${u_plane_ip_2} && ip.dst==${remote_tunnel_ip} " 2>/tmp/stderr.txt
    Should Be Empty   ${output}


BEIF LOS Alarm should Exist
	[Arguments]		${alias}=default
	Verify Alarm		faultid=61029		alias=${alias}

BEIF LOS Mode Alarm should Not Exist
	[Arguments]		${alias}=default
	Verify Alarm		faultid=61029		should_exist=${False}	alias=${alias}

DPD Alarm should Exist
	[Arguments]		${occurrences}=1	${alias}=default
	Verify Alarm		faultid=61030		occurrences=${occurrences}	alias=${alias}

DPD Alarm should Not Exist
	[Arguments]		${alias}=default
	Verify Alarm		faultid=61030		should_exist=${False}	alias=${alias}

Get LMP eth1 MAC address
	${Internal_mac_address}=		Run		sudo ifconfig eth1 | grep ether | awk -F ' ' '{print $2}'
	Set Suite Variable	${Internal_mac_address}	${Internal_mac_address}

Start Point A Traffic File Capture
	 Traffic Capture Start	capture_device=oam_device	mode=file	measurement_point=NE_Terminated	uplane_capturing=True
	 ...   timeout=120	alias=no_password

Stop Point A Traffic File Capture
	${PointA_noPwd}=   Traffic Capture Stop   mode=file  alias=no_password  timeout=350
	Analyse Pcap 	pcap_filename=${PointA_noPwd} 	analysis=verify_noesp		filter_file_name=${filter_file_name}

Start Point A Traffic Stream Capture
	Traffic Capture Start	capture_device=LMP_PC	capture_filter=vlan	alias=capture_streaming_a
	Traffic Capture Start	capture_device=oam_device	mode = streaming	measurement_point=NE_Terminated	uplane_capturing=True
	...    dst_mac_addr=${Internal_mac_address}	egress_port_dn=LMP	timeout=120	alias=capture_streaming_b

Stop Point A Traffic Stream Capture
    	Traffic Capture Stop	mode=streaming	alias=capture_streaming_b
        ${filename_A}=	Traffic Capture Stop	capture_device=LMP_PC	capture_filter=vlan	alias=capture_streaming_a	timeout=120
        Analyse Pcap 		pcap_filename=${filename_A} 	analysis=verify_noesp			filter_file_name=${filter_file_name}

Point B Traffic File Capture
	 Traffic Capture Start	capture_device=oam_device	mode=file	measurement_point=Transport_Interface	uplane_capturing=${True}
	 ...   timeout=120	alias=No_password
	 Sleep   60
	 Verify Alarm        	faultid=61641
    	 ${PointB_noPwd}=	Traffic Capture Stop	mode=file	alias=No_password	timeout=120
	 Verify Alarm        	faultid=61641 	should_exist=${False}
	 Analyse Pcap	pcap_filename=${PointB_noPwd} 	analysis=verify_esp	filter_file_name=${filter_file_name}

Point B Traffic Stream Capture
	Traffic Capture Start	capture_device=LMP_PC	capture_filter=esp	alias=capture_streaming_b
	Traffic Capture Start        capture_device=oam_device    mode = streaming		measurement_point=Transport_Interface
	...    uplane_capturing=True	dst_mac_addr=${Internal_mac_address}	egress_port_dn=LMP	timeout=120	alias=capture_streaming_a
	Sleep	60
    	Traffic Capture Stop	mode=streaming	alias=capture_streaming_a
	${filename_B}=	Traffic Capture Stop	capture_device=LMP_PC	capture_filter=esp		alias=capture_streaming_b
	Analyse Pcap 		pcap_filename=${filename_B} 	analysis=verify_esp	filter_file_name=${filter_file_name}

        collect snapshot
        Run Keyword And Ignore Error	Call Stop	lte=device_1:data	profile=udp_ul
	Run Keyword And Ignore Error	Call Stop	lte=device_1:data	profile=udp_dl
	Run Keyword And Ignore Error	Call Stop	wcdma=device_1:data	profile=udp_ul_wcdma
	Run Keyword And Ignore Error	Call Stop	wcdma=device_1:data	profile=udp_dl_wcdma
	Call Stop	gsm=device_1:voice

	#[Teardown]	Configure Switch	device=bfd1_router	command_profile=del_route_IPSEC
	[Teardown]	PostConditions

Check whether Ipv6 Control Server does reply on ping
    Download BTS_TRS File from eNB
   ${cntrlserverIP}=    Get Element text   /tmp/192.168.255.129_scf.xml
   ...     .//managedObject[@distName="MRBTS-1/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1"]/p[@name="ipSecEmBypassCtrlIpAddr"]
    Should Match Regexp  '${cntrlserverIP}'     fc\\d{1,2}\:\:\\d{1,2}
    Set Suite Variable   ${cntrlserverIP}       ${cntrlserverIP}
    sleep       120
    Execute command on ENodeB       ping6 -c 5 ${cntrlserverIP}
    Should Match Regexp      '${stdout}'      5\\s*received


Check for no security associates on eNB with IPv6 Configuration
    Download BTS_TRS File from eNB
	Get UCMS Planes' IPv6 IP's
	${ssh_enb_handle}      Open Connection    ${enb_ip}
    Login                  ${enb_root_user}    ${enb_root_passwd}
	Switch Connection      ${ssh_enb_handle}
	${stdout}  ${stderr}   Execute Command        ipsec status|grep ${enb_uPlane_ipv6}|grep ${s1linkIPv6}
	...    return_stdout=${True}  return_stderr=${True}
    Should Be Empty     ${stdout}
    ${stdout}  ${stderr}   Execute Command        ipsec status|grep ${enb_cPlane_ipv6}|grep ${s1linkIPv6}
    ...   return_stdout=${True}  return_stderr=${True}
    Should Be Empty     ${stdout}
    ${stdout}  ${stderr}   Execute Command        ipsec status|grep ${enb_mPlane_ipv6}|grep ${s1linkIPv6}
    ...    return_stdout=${True}  return_stderr=${True}
    Should Be Empty     ${stdout}
#    ${stdout}  ${stderr}   Execute Command        ipsec status|grep ${S_PLANE_IP}    return_stdout=${True}  return_stderr=${True}
#    Should Be Empty     ${stdout}
    Close Connection

Check for IPsec failure Alarm
    Download Alarm File from eNB
	${ELEMENT} = 		Set Variable 	Dead Peer Detected
	Should Contain		${SEM_alarms}		${ELEMENT}

Check for No IPsec failure Alarm
    Download Alarm File from eNB
	${ELEMENT} = 		Set Variable 	Dead Peer Detected
	Should Not Contain		${SEM_alarms}		${ELEMENT}

Check for active alarm while Emergencybypass is in use
    Download Alarm File from eNB
	${ELEMENT} = 	Set Variable 	IPsec emergency bypass active
	Should Contain		${SEM_alarms}		${ELEMENT}

Check for active alarm while Emergencybypass is NOT in use
	Download Alarm File from eNB
	${ELEMENT} = 	Set Variable 	IPsec emergency bypass active
	Should Not Contain		${SEM_alarms}		${ELEMENT}

Check whether Ipv6 Control Server does not reply on ping
    Download BTS_TRS File from eNB
	${cntrlserverIP}=    Get Element text   /tmp/192.168.255.129_scf.xml
	...    .//managedObject[@distName="MRBTS-1/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1"]/p[@name="ipSecEmBypassCtrlIpAddr"]
    Should Match Regexp  '${cntrlserverIP}'     fc\\d{1,2}\:\:\\d{1,2}
    Set Suite Variable   ${cntrlserverIP}       ${cntrlserverIP}
    Execute command on ENodeB       ping6 -c 5 ${cntrlserverIP}
	Should Match Regexp      '${stdout}'      0\\s*received

Check whether S1 messages are unencrypted for IPV6
	Check cell state
    Perform attach for single UE
    Sleep   10
	Run     sudo timeout 60 tcpdump -ni eth3 -w /tmp/tshark_out_ipsec 1>/dev/null &
	Start data transmission for '${ue_id}' UE in 'ul' direction with throughput '4' 'mbps' 'tcp'
    Sleep   20
    Stop data transmission for '${ue_id}' UE
	Sleep   40
	Copy File		/tmp/tshark_out_ipsec		${OUTPUT DIR}/BTSSM_CLI_Tool_Logs/
    Perform detach for single UE
    Download BTS_TRS File from eNB
    Get UCMS Planes' IPv6 IP's
    ${tshark_content}=      Run  tshark -r /tmp/tshark_out_ipsec -Y "esp" 2>/dev/null
    Log         ${tshark_content}
    Should Be Empty         ${tshark_content}
    ${rc}   ${stdout}=     Run and Return RC and Output    tshark -r /tmp/tshark_out_ipsec -Y "ipv6.src==${enb_uPlane_ipv6}&&gtp" 2>/dev/null
    Should Not Be Empty     ${stdout}
    ${rc}   ${stdout}=     Run and Return RC and Output    tshark -r /tmp/tshark_out_ipsec -Y "ipv6.dst==${enb_uPlane_ipv6}&&gtp" 2>/dev/null
    Should Not Be Empty     ${stdout}
    ${rc}   ${stdout}=     Run and Return RC and Output    tshark -r /tmp/tshark_out_ipsec -Y "ipv6.src==${enb_cPlane_ipv6}&&sctp" 2>/dev/null
    Should Not Be Empty     ${stdout}
    ${rc}   ${stdout}=     Run and Return RC and Output    tshark -r /tmp/tshark_out_ipsec -Y "ipv6.dst==${enb_cPlane_ipv6}&&sctp" 2>/dev/null
    Should Not Be Empty     ${stdout}

Verify Data Rate in wireshark
    [Arguments]         ${pcap_file}        ${filter}       ${expected_data_rate}
    Run  tshark -r ${pcap_file} -Y "${filter}" -w ${EXECDIR}/ue_shaping 2>/dev/null
    ${data_rate}=  Run  capinfos ${EXECDIR}/ue_shaping -i | tail -1 | awk '{ print $4 }'
    ${data_rate}=        Remove String       ${data_rate}     ,
    Set Suite Variable     ${data_rate}
    ${higher_limit}=        Evaluate        ${expected_data_rate}+200
    ${lower_limit}=         Evaluate            ${expected_data_rate}-200
    Should Be True      ${data_rate}>${lower_limit}
    Should Be True      ${data_rate}<${higher_limit}
