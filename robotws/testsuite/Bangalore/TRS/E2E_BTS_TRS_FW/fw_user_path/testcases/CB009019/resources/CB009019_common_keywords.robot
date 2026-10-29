*** Settings ***
Documentation
...		[Author]     		        "Nupur"
...		[Maintenance]		        "TRS I&V Tools Bangalore Team"
...		[Date] 			            "19:05:2021"
...		[Feature_ID] 		        "CB006557"

*** Variables ***
@{AMF_IP_List}
@{MME_IP_List}
@{NGU_IP_List}
@{NGC_IP_List}
@{LTE_C_IP_List}
@{LTE_U_IP_List}
@{NRADJ_C_IP_List}
*** Keywords ***
Delete IP Interface from eth3
    [Arguments]      ${IP_list}
	FOR   ${IP}  IN   @{IP_list}
		Run     sudo ip a delete ${IP} dev eth3
	END

Delete Vlan Interface of eth3
    [Arguments]      ${Vlan_list}
	FOR   ${vlanid}  IN   @{Vlan_list}
	   Run    sudo ip link delete dev ${vlanid}
	END

Attach UE with operator specific qci and send ul traffic
    [Arguments]          ${operator}       ${profile}
	Configure UE       5g=${profile}:data  command=ue_register  id=${operator}  profile=${operator}
    sleep  5
	Configure UE       5g=${profile}:data  command=set_pdu_param  ue=${operator}   pdu=${operator}  trf_type=internal
    sleep  5
    Configure UE       5g=${profile}:data  command=ue_pdu_session_setup  pdu=${operator}  ue=${operator}  nwslice=${operator}  gw=${operator}
    sleep  5
    Configure UE       5g=${profile}:data  command=trf_data_start  ue=${operator}  pdu=${operator}    qfi=1   dir=dl   mbps=20
    sleep  10


Attach UE with operator specific qci and send dl traffic
    [Arguments]          ${operator}       ${profile}
	Configure UE       5g=${profile}:data  command=ue_register  id=${operator}  profile=${operator}
    sleep  5
	Configure UE       5g=${profile}:data  command=set_pdu_param  ue=${operator}   pdu=${operator}  trf_type=internal
    sleep  5
    Configure UE       5g=${profile}:data  command=ue_pdu_session_setup  pdu=${operator}  ue=${operator}  nwslice=${operator}  gw=${operator}
    sleep  5
    Configure UE       5g=${profile}:data  command=trf_data_start  ue=${operator}  pdu=${operator}    qfi=1   dir=dl   mbps=20
    sleep  10


Attach UE with operator specific qci and send ul dl traffic
    [Arguments]          ${operator}       ${profile}
	Configure UE       5g=${profile}:data  command=ue_register  id=${operator}  profile=${operator}
    sleep  5
	Configure UE       5g=${profile}:data  command=set_pdu_param  ue=${operator}   pdu=${operator}  trf_type=internal
    sleep  5
    Configure UE       5g=${profile}:data  command=ue_pdu_session_setup  pdu=${operator}  ue=${operator}  nwslice=${operator}  gw=${operator}
    sleep  5
    Configure UE       5g=${profile}:data  command=trf_data_start  ue=${operator}  pdu=${operator}    qfi=1   dir=ul   mbps=20
    sleep  1
    Configure UE       5g=${profile}:data  command=trf_data_start  ue=${operator}  pdu=${operator}    qfi=1   dir=dl   mbps=20
    sleep  10

Verify NG link Status
	[Arguments]          ${operators}=1
	${index}=     Evaluate      ${operators}+1
	FOR   ${operator}   IN RANGE   1   ${index}
	      ${operator_str}=	   Convert To String	    ${operator}
	      ${NG_status}=       Query Admin Infomodel    query=get object ${amf_moc_path}-${operator_str}
		   ${ng_link_status}=     Get From Dictionary     dictionary=${NG_status}      key=ngLinkStatus
          Should Be Equal		${ng_link_status}		Active
    END

Verify Xn link Status
	[Arguments]          ${operators}=1
	${index}=     Evaluate      ${operators}+1
	FOR   ${operator}   IN RANGE   1   ${index}
	      ${operator_str}=	   Convert To String	    ${operator}
	      ${Xn_status}=      Query Admin Infomodel    query=get object ${Xn_link_path}-${operator_str}
          ${Xn_link_status}=       Get From Dictionary     ${Xn_status}      xnLinkStatus
          Should Be Equal    ${Xn_link_status}      available
    END

Verify S1 link Status
	[Arguments]          ${operators}=1
	FOR   ${operator}   IN RANGE   0   ${operators}
	      ${operator_str}=	   Convert To String	    ${operator}
	      ${S1_status}=      Query Admin Infomodel    query=get object ${mme_moc_path}-${operator_str}
          ${S1_link_status}=       Get From Dictionary     ${S1_status}      s1LinkStatus
          Should Be Equal    ${S1_link_status}      available
    END

Stop traffic and detach UE
    [Arguments]          ${operator}       ${profile}
	Configure UE       5g=${profile}:data  command=ue_pdu_session_release  ue=${operator}    pdu=${operator}
    Sleep   50
    Configure UE       5g=${profile}:data  command=ue_deregister  id=${operator}  ue_deregister_type=switch_off
	Sleep   5

Get IP Version
	[Arguments]        ${ip}
	${contains}=  Evaluate   ":" in """${ip}"""
	Run Keyword IF      '${contains}'=='True'       Set Suite Variable      ${version}    ipV6
    ...    ELSE       	Set Suite Variable      ${version}    ipV4

Get AMF IP Address
	[Arguments]          ${operator}=1

	${index}=    Evaluate      ${operator}+1
	FOR   ${operator}   IN RANGE   1   ${index}
		${amf_dict}=      Query Admin Infomodel    query=get object ${amf_path}-${operator}
    	${amf_ip}=       Get From Dictionary       ${amf_dict}    amfIPAddress
	    Append To List    ${AMF_IP_List}    ${amf_ip}
	END

Get MME IP Address
	[Arguments]          ${index}=1

	FOR   ${operator}   IN RANGE   0   ${index}
		${mme_dict}=      Query Admin Infomodel    query=get object ${mme_path}-${operator}
    	${mme_ip}=       Get From Dictionary       ${mme_dict}    ipAddrPrim
	    Append To List    ${MME_IP_List}    ${mme_ip}
	END

Get NG-U IP Address
 	[Arguments]        ${IP_Version}     ${index}=1

	${nrbts_dict}=    Query Admin Infomodel    query=get object ${nrbts_path}
	${nguplane_list}=    Get From Dictionary     dictionary=${nrbts_dict}      key=ngUplane
	FOR   ${operator}   IN RANGE   0   ${index}
		${nguplane_add}=   Get from list       ${nguplane_list}        ${operator}
		${nguplane_moc}=    Get From Dictionary     ${nguplane_add}       ${IP_Version}AddressDN1
		${nguplane_ipif}=   Query Admin Infomodel     query=get object ${nguplane_moc}
		${nguplane_ip}=    Get From Dictionary      ${nguplane_ipif}      localIpAddr
		Append To List    ${NGU_IP_List}    ${nguplane_ip}
    END

Get NG-C IP Address
 	[Arguments]        ${IP_Version}     ${index}=1

	${nrbts_dict}=    Query Admin Infomodel    query=get object ${nrbts_path}
	${ngcplane_list}=    Get From Dictionary     dictionary=${nrbts_dict}      key=ngCplane
	FOR   ${operator}   IN RANGE   0   ${index}
		${ngcplane_add}=   Get from list       ${ngcplane_list}        ${operator}
		${ngcplane_moc}=    Get From Dictionary     ${ngcplane_add}       ${IP_Version}AddressDN1
		${ngcplane_ipif}=   Query Admin Infomodel     query=get object ${ngcplane_moc}
		${ngcplane_ip}=    Get From Dictionary      ${ngcplane_ipif}      localIpAddr
		Append To List    ${NGC_IP_List}    ${ngcplane_ip}
	END

Get NRADJ IP Address
 	[Arguments]         ${operators}=1
	${index}=     Evaluate      ${operators}+1
	FOR   ${operator}   IN RANGE   1   ${index}
       ${nradj_cplane}=    Query Admin Infomodel    query=get object ${Xn_link_path_A}-${operator}
		${nradj_cplane_ip}=       Get From Dictionary     ${nradj_cplane}     cPlaneIpAddr
		Append To List    ${NRADJ_C_IP_List}    ${nradj_cplane_ip}
	END

Get LTE-C IP Address
 	[Arguments]        ${IP_Version}     ${index}=1

	FOR   ${operator}   IN RANGE   0   ${index}
		${LTE_C_IP}=      Get Parameter      param_path=TRSNW-${operator}:cPlane:${IP_Version}AddressDN1:localIpAddr
		Append to List     ${LTE_C_IP_List}      ${LTE_C_IP}
	END

Get LTE-U IP Address
 	[Arguments]        ${IP_Version}     ${index}=1

	FOR   ${operator}   IN RANGE   0   ${index}
		${LTE_U_IP}=      Get Parameter      param_path=TRSNW-${operator}:uPlane:${IP_Version}AddressDN1:localIpAddr
		Append to List     ${LTE_U_IP_List}      ${LTE_U_IP}
    END

Delete IP List Address
	FOR     ${ip}    IN    @{AMF_IP_List}
    	Remove values from list    ${AMF_IP_List}    ${ip}
    END

	FOR     ${ip}    IN    @{MME_IP_List}
    	Remove values from list    ${MME_IP_List}    ${ip}
    END

	FOR     ${ip}    IN    @{NGU_IP_List}
    	Remove values from list    ${NGU_IP_List}    ${ip}
    END

	FOR     ${ip}    IN    @{NGC_IP_List}
    	Remove values from list    ${NGC_IP_List}    ${ip}
    END

	FOR     ${ip}    IN    @{LTE_C_IP_List}
    	Remove values from list    ${LTE_C_IP_List}    ${ip}
    END

	FOR     ${ip}    IN    @{LTE_U_IP_List}
    	Remove values from list    ${LTE_U_IP_List}    ${ip}
    END

	FOR     ${ip}    IN    @{NRADJ_C_IP_List}
    	Remove values from list    ${NRADJ_C_IP_List}    ${ip}
    END

Start iperf for server
	Process.Start Process    iperf -s -m -p ${port} -i 1 -M ${iPMtu} -B ${server_ip} -t ${count} &  shell=True

Start iperf for client for UL
	Process.Start Process	iperf -c ${nat_ip_ul} -m -p ${port} -l ${length} -i 1 -t ${count} -M ${iPMtu} -B ${server_ip} &

Start iperf for client for DL
	Process.Start Process	iperf -c ${nat_ip_dl} -m -p ${port} -l ${length} -i 1 -t ${count} -M ${iPMtu} -B ${server_ip} &

Stop iperf server
    Run    sudo killall iperf

Keyword to Run at end
    Run     sudo killall edaemon egate

Add Vlan Interface on Vm
    [Arguments]     ${vlan1}=800     ${vm_vlan_interface_ipv4}=${ipv4}     ${subnet}=${ipv4_subnet}      ${vm_vlan_interface_ipv6}=${ipv6}
    ... 	${ipv6_subnet}=${ipv6_subnet}
    Run     sudo ip link add link eth3 name eth3.${vlan1} type vlan id ${vlan1}
    Run     sudo ip addr add ${vm_vlan_interface_ipv4}/${subnet} dev eth3.${vlan1}
    Run     sudo ip addr add ${vm_vlan_interface_ipv6}/${ipv6_subnet} dev eth3.${vlan1}
    Run     sudo ip link set dev eth3.${vlan1} up

Add Simulated Ips
    FOR   ${ip}   IN    @{Simulated_Vm_Ipv4_Ips}
		Run    sudo ip addr add ${ip}/${subnet} dev eth3
    END
    FOR   ${ip}   IN    @{Simulated_Vm_Ipv6_Ips}
		Run    sudo ip -6 addr add ${ip}/${ipv6_subnet dev eth3
	END

Verify NGAP and S1AP Messages
	Verify Alarm     faultid=${alarm_ngap}   severity=critical     should_exist=True    occurrences=12
	Verify Alarm     faultid=${alarm_s1ap}   should_exist=True    occurrences=12
    Traffic capture start           capture_device=vm_eth3_interface 		alias=ngap_s1ap
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
	    Get IP Version      ${amf_ip}
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
	    Get IP Version      ${mme_ip}
		Analyse Pcap        pcap_filename=${pcap_file}        analysis=s1ap_setup_${version}
	    ...	filter_file_name=${traffic_filter_file_name}
		Analyse Pcap        pcap_filename=${pcap_file}        analysis=s1ap_response_${version}
	    ...	filter_file_name=${traffic_filter_file_name}
	END

Start iperf for client for UL NSA
    	Process.Start Process	iperf -c ${nat_ip_ul} -m -p ${port} -l ${length} -i 1 -t ${count} -M ${iPMtu} -B ${server_ip} &

Start iperf for client for DL NSA
    Process.Start Process	iperf -c ${nat_ip_dl} -m -p ${port} -l ${length} -i 1 -t ${count} -M ${iPMtu} -B ${server_ip} &

Check iperf process and killall
    ${output}=  Run     sudo ps -eaf | grep iperf
    Log     ${output}
    @{first}=   Split To Lines   ${output}
    FOR    ${ELEMENT}    IN    @{first}
           @{words}=       Split string    ${ELEMENT}
           ${pid}=     Get from list        ${words}     1
           Run     sudo kill -9 ${pid}
    END

Change MSS value and verify it
    Perform Recommissioning 	type=param 	 	param_path=MRBTS-1/LNBTS-1/GTPU-1:udpMaxDatagramSize 	operation=update
	...	value=${tcp_value}  timeout=300
    Perform Recommissioning     type=param      param_path=MRBTS-1/NRBTS-1:udpMaxDatagramSize    operation=update
	...	value=${tcp_value}  timeout=300
    ${nsa_mss_value}=       Evaluate    ${udp}-${nsa_value}
    ${sa_mss_value}=        Evaluate    ${udp}-${sa_value}

Attach UE_NSA
	Configure UE       5g=device3:data  command=ue_attach  id=${id} profile=${ue}
    Configure UE       5g=device3:data  command=ue_measurement_send   id=${id} phycell_id=${phy} nrsrp=${nrsrp} event=B1_NR
    Configure UE       5g=device3:data  command=ue_measurement_send id=${id} phycell_id=${phy} nr_cgi_plmn_ident_info_id=${id}
	...	nr_cgi_cell_ident=${id}     nr_cgi_plmns_ident=${plmn}    nrsrp=${nrsrp}       event=B1_NR
    Configure UE       5g=device3:data  command=ue_measurement_send id=${id}   event=B1_NR nrsrp=${nrsrp}   phycell_id=${phy}
    Block Cell      rat=nr
    Sleep    120
    Unblock Cell    rat=nr
    Sleep    60
    Call Setup      lte=device4:data   parallel=${False}    verify_attach=${False}   attach=${False}   timeout=300
    Sleep   60
    Configure UE       lte=device4:data  command=ue_mme_param id=${id} sgw_id={ue}
    Configure UE       lte=device4:data  command=ue_sgw_param id=${id} s1u_preferred_ip_ver={ue}
    Configure UE       lte=device4:data  command=ue_attach id=${id} profile=${ue}
    Configure UE       lte=device4:data  command=ue_measurement_send id=${id} phycell_id=${phy} nrsrp=${nrsrp} event=B1_NR
    Sleep   5

Verify MSS value for NSA
    Analyse Pcap        pcap_filename=${pcap_file}        analysis=nsa_call_mss_value_ul   filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${pcap_file}        analysis=nsa_call_mss_value_dl   filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${pcap_file}        analysis=nsa_call_ul_ipV4        filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${pcap_file}        analysis=nsa_call_dl_ipV4        filter_file_name=${traffic_filter_file_name}


Verify MSS value for SA
    Analyse Pcap        pcap_filename=${pcap_file}        analysis=sa_call_mss_value_ul_changed
	...	filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${pcap_file}        analysis=sa_call_mss_value_dl_changed
	...	filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${pcap_file}        analysis=sa_call_ul_ipV4
	...	filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${pcap_file}        analysis=sa_call_dl_ipV4
	...	filter_file_name=${traffic_filter_file_name}

Verify wireshark MSS value changes for SA
     Analyse Pcap        pcap_filename=${pcap_file}        analysis=sa_call_mss_value_ul_changed
	...	filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${pcap_file}        analysis=sa_call_mss_value_dl_changed
	...	filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${pcap_file}        analysis=sa_call_ul_ipV4
	...	filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${pcap_file}        analysis=sa_call_dl_ipV4
	...	filter_file_name=${traffic_filter_file_name}
