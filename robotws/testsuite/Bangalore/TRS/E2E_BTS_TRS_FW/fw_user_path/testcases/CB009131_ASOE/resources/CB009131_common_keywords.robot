*** Settings ***
Documentation
Variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../../resources/common_keywords.robot
Resource        ${CURDIR}/../../resources/Admin_Common_Library.robot
*** Variables ***
@{5g_nsa_nrbts_dict}
*** Keywords ***
Test run complete
    Run Keyword And Ignore Error    Call Teardown     5g=device1_nsa_dualstack:data
    Run         sudo killall egate edaemon

Verify Alarms
    Download Alarm File from eNB
Perform 5G call for uplink traffic
    [Arguments]      ${mtu_value}
    Traffic capture start           capture_device=vm_eth3_interface
    Setup Remote Access    remote_device=bts
    Run     sudo killall egate edaemon
    Call Setup      5g=device2:data  parallel=${False}  verify_attach=${False}
    ...  ipv4_or_6=ipv4  attach=${False}     timeout=1200
    Block    operation=Cell    rat=NR
    Sleep    120
    Unblock    operation=Cell    rat=NR
    Sleep    200
    Configure UE       5g=device2:data    command=ue_attach  id=11  profile=1
    Sleep   5
    Configure UE       5g=device2:data    command=enb_ue_dc_start  ue=11  target_gnb=2
    ...  target_cells=1  bearer=1  type=split_scg
    Sleep   5
    Configure UE      5g=device2:data    command=trf_data_start  ue=11  id=1  dir=ul
    ...  trf_id=1  size=${mtu_value}
    Configure UE      5g=device2:data    command=trf_data_start  ue=11  id=1  dir=dl
    ...  trf_id=2  size=${mtu_value}
    Sleep   600
    Run Keyword And Ignore Error    Call Stop  5g=device2:data  profile=${udp_ul_profile}
    Call Teardown   5g=device2:data
    Teardown remote Access
    ${pcap_file}=   Traffic Capture Stop
    Set Suite Variable     ${pcap_file}     ${pcap_file}
    Analyse Pcap        pcap_filename=${pcap_file}        analysis=NSA_call_ul_ipV6
    ...      filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${pcap_file}        analysis=NSA_call_dl_ipV6
    ...      filter_file_name=${traffic_filter_file_name}
Perform 5G call for uplink traffic for modified IP
    [Arguments]      ${mtu_value}
    Traffic capture start           capture_device=vm_eth3_interface
    Setup Remote Access    remote_device=bts
    Run     sudo killall egate edaemon
    Call Setup      5g=device2_IPmod:data  parallel=${False}  verify_attach=${False}
    ...  ipv4_or_6=ipv4  attach=${False}     timeout=1200
    Sleep   120
    Block    operation=Cell    rat=NR
    Sleep    120
    Unblock    operation=Cell    rat=NR
    Sleep    200
    Configure UE       5g=device2_IPmod:data    command=ue_attach  id=11  profile=1
    Sleep   5
    Configure UE       5g=device2_IPmod:data    command=enb_ue_dc_start  ue=11
    ...  target_gnb=2  target_cells=1  bearer=1  type=split_scg
    Sleep   5
    Configure UE      5g=device2_IPmod:data    command=trf_data_start  ue=11
    ...  id=1  dir=ul  trf_id=1  size=${mtu_value}
    Configure UE      5g=device2_IPmod:data    command=trf_data_start  ue=11
    ...  id=1  dir=dl  trf_id=2  size=${mtu_value}
    Sleep   600
    Run Keyword And Ignore Error    Call Stop  5g=device2_IPmod:data  profile=${udp_ul_profile}
    Call Teardown   5g=device2_IPmod:data
    Teardown remote Access
    ${pcap_file}=   Traffic Capture Stop
    Set Suite Variable     ${pcap_file}     ${pcap_file}
    Analyse Pcap        pcap_filename=${pcap_file}        analysis=NSA_call_ul_ipV6_ipmod
    ...      filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${pcap_file}        analysis=NSA_call_dl_ipV6_ipmod
    ...      filter_file_name=${traffic_filter_file_name}

Download Alarm File from eNB
    ${alarms}=      Get Active Alarms
    Set Suite Variable      ${Active_alarms}        ${alarms}
    @{SEM_alarms}=      Create List
    ${Dict}=    Create Dictionary
    ${len}=     Get Length      ${Active_alarms}
    :FOR    ${i}    IN RANGE    0   ${len}
    \       Log Dictionary      @{alarms}[${i}]
    \       ${val}=     Get From Dictionary     @{alarms}[${i}]     faultId
    \       Append To List      ${SEM_alarms}       ${val}
    \       Set To Dictionary   ${Dict}     ${i}    ${val}
    Set Suite Variable      ${SEM_alarms}       ${SEM_alarms}
    Log     ${SEM_alarms}}
    Set Suite Variable      ${Dict}     ${Dict}
    Log     ${Dict}

Read parameter values
    ${lte_v4_cplane_ip}=       Get Parameter   param_path=${lte_cplane_v4_moc_path}
    Set Suite Variable       ${lte_v4_cplane_ip}
    ${lte_v6_cplane_ip}=       Get Parameter   param_path=${lte_cplane_v6_moc_path}
    Set Suite Variable       ${lte_v6_cplane_ip}
    ${lte_v4_uplane_ip}=       Get Parameter   param_path=${lte_uplane_v4_moc_path}
    Set Suite Variable       ${lte_v4_uplane_ip}
    ${lte_v6_uplane_ip}=       Get Parameter   param_path=${lte_uplane_v6_moc_path}
    Set Suite Variable       ${lte_v6_uplane_ip}
    ${x2_v4_cplane_ip}=       Get Parameter   param_path=${x2_cplane_v4_moc_path}
    Set Suite Variable       ${5g_nsa_x2_cplane_ipv4}       ${x2_v4_cplane_ip}
    ${x2_v6_cplane_ip}=       Get Parameter   param_path=${x2_cplane_v6_moc_path}
    Set Suite Variable       ${5g_nsa_x2_cplane_ipv6}        ${x2_v6_cplane_ip}
    ${lnmme_v4}=     Get Parameter   param_path=${lnmme_v4_moc_path}
    Set Suite Variable       ${lnmme_v4}

Add routes on VM
    Run        sudo ip a a 10.0.1.121 dev eth3
    Run        sudo ip a a 10.0.1.131 dev eth3
    Run        sudo ip a a 10.0.1.132 dev eth3
    Run        sudo ip a a 10.0.1.135 dev eth3
    Run        sudo ip a a 10.0.1.136 dev eth3
    Run        sudo ip a a 10.0.1.137 dev eth3
    Run        sudo ip a a 10.0.1.133 dev eth3
    Run        sudo ip a a 10.0.1.134 dev eth3
    Run        sudo ip a a fc00::1/120 dev eth3

Add routes on VMranssharing
    Run  sudo ip a a fc00::10/120 dev eth3
    Run   sudo ip a a fc00::11/120 dev eth3
    Run sudo ip a a fc00::12/120 dev eth3
	Run sudo ip a a fc00::13/120 dev eth3
	Run sudo ip a a fc00::14/120 dev eth3
	Run sudo ip a a fc00::15/120 dev eth3
	Run sudo ip a a fc00::16/120 dev eth3
	Run sudo ip a a fc00::17/120 dev eth3
	Run sudo ip a a fc00::18/120 dev eth3
	Run sudo ip a a fc00::19/120 dev eth3
	Run sudo ip a a fc00::20/120 dev eth3
	Run sudo ip a a fc00::21/120 dev eth3
	Run sudo ip a a fc00::22/120 dev eth3
	Run sudo ip a a fc00::23/120 dev eth3
    Run sudo ip a a 10.0.1.131/24 dev eth3
    Run sudo ip a a 10.0.1.132/24 dev eth3
    Run sudo ip a a 10.0.1.133/24 dev eth3
    Run  sudo ip a a 10.0.1.134/24 dev eth3
    Run  sudo ip a a 10.0.1.135/24 dev eth3
    Run  sudo ip a a 10.0.1.136/24 dev eth3
    Run  sudo ip a a 10.0.1.137/24 dev eth3
    Run  sudo ip a a 10.0.1.143/24 dev eth3
	Run sudo ip a a 10.0.1.144/24 dev eth3
	Run sudo ip a a 10.0.1.150/24 dev eth3
	Run sudo ip a a 10.0.1.151/24 dev eth3
	Run sudo ip a a 10.0.1.152/24 dev eth3
	Run sudo ip a a 10.0.1.153/24 dev eth3
	Run sudo ip a a 10.0.1.154/24 dev eth3
	Run sudo ip a a 10.0.1.160/24 dev eth3
	Run sudo ip a a 10.0.1.161/24 dev eth3
	Run sudo ip a a 10.0.1.162/24 dev eth3
	Run sudo ip a a 10.0.1.163/24 dev eth3
	Run sudo ip a a 10.0.1.164/24 dev eth3
	Run  sudo ip a a 10.0.1.140/24 dev eth3
	Run sudo ip a a 10.0.1.141/24 dev eth3
	Run sudo ip a a 10.0.1.142/24 dev eth3
	Run sudo ip a a 10.0.1.143/24 dev eth3
	Run sudo ip a a 10.0.1.144/24 dev eth3

    Setup Remote Access	remote_device=bts
	${mac_address}=		Remote Command Execute
    ...		command=ifconfig br1 | grep ether | awk '{print $2}'
    Set Suite Variable       ${mac_address}
    @{5g_nsa_x2_cplane_ipv4_list}=  Create List
    @{5g_nsa_x2_cplane_ipv6_list}=  Create List
	${5g_nsa_nrbts_dict}=       Query Admin Infomodel       query=get list ${nrbts_moc_path}
    ${5g_nsa_x2_cplane_ip_list}=    Get From Dictionary	dictionary=@{5g_nsa_nrbts_dict}[0]    key=${x2Cplane_param_name}
    :FOR    ${ip_dict}  IN  @{5g_nsa_x2_cplane_ip_list}
        \   ${5g_nsa_x2_cplane_ipv4_dn}=    Get From Dictionary		dictionary=${ip_dict}
        ...   key=${ipV4AddressDN1_param_name}
        \   ${ipv4}=            Get Parameter   param_path=${5g_nsa_x2_cplane_ipv4_dn}:${localIpAddr_param_name}
        \   Append To List  ${5g_nsa_x2_cplane_ipv4_list}   ${ipv4}
        \  ${ipv6}=            Get Parameter   param_path=${5g_nsa_x2_cplane_ipv6_dn}:${localIpAddr_param_name}
        \   Append To List  ${5g_nsa_x2_cplane_ipv6_list}   ${ipv6}
    ${5g_nsa_x2_cplane_ipv4}=       Set Variable    @{5g_nsa_x2_cplane_ipv4_list}[0]
    ${5g_nsa_x2_cplane_ipv6}=       Set Variable    @{5g_nsa_x2_cplane_ipv6_list}[0]
    Set Suite Variable       ${5g_nsa_x2_cplane_ipv4}
    Set Suite Variable       ${5g_nsa_x2_cplane_ipv6}
 	[Teardown]	Teardown Remote Access

Send Packet From Unknown Source
    [Arguments]     ${ip_version}   ${profile1}
    ${traffic_profile}=	Set Variable If		'${ip_version}'=='ipv4'	    ${profile1}
    ...		'${ip_version}'=='ipv6'	    ${profile1}
	Traffic Setup           device=device_1
    ${packet_speed}     ${time} =       Traffic Start       profile=${traffic_profile}
    Traffic Teardown
    ${packets}=     Evaluate    ${packet_speed} * ${time}
    Set Suite Variable      ${packets}      ${packets}
    Set Suite Variable      ${packet_speed}     ${packet_speed}
    Set Suite Variable      ${time}     ${time}
    [Teardown]      Run Keyword And Ignore Error        Traffic Teardown

Get X2C_IP Address
 	[Arguments]          ${operator}        ${IP_Version}
    ${index}=       Run Keyword If    '${operator}'=='1'    Set variable     0    ELSE IF
    ...    '${operator}'=='8'    Set variable     1     ELSE IF      '${operator}'=='9'
    ...     Set variable     2
	${nrbts_dict}=    Query Admin Infomodel    query=get object ${nrbts_path}
	${x2Cplane_list}=    Get From Dictionary     dictionary=${nrbts_dict}      key=x2Cplane
	${X2Cplane_add}=   Get from list       ${X2Cplane_list}        ${index}
	${X2Cplane_moc}=    Get From Dictionary     ${X2Cplane_add}       ${IP_Version}AddressDN1
	${X2Cplane_ipif}=   Query Admin Infomodel     query=get object ${X2Cplane_moc}
	${X2Cplane_ip}=    Get From Dictionary      ${X2Cplane_ipif}      localIpAddr
    Set Suite Variable     ${5g_nsa_x2_cplane_ip}      ${X2Cplane_ip}
Get S1U_IP Address
	${index}=    Evaluate      ${operator}-1
	${nrbts_dict}=    Query Admin Infomodel    query=get object ${nrbts_path}
	${s1Uplane_list}=    Get From Dictionary     dictionary=${nrbts_dict}      key=s1Uplane
	${s1Uplane_add}=   Get from list       ${S1Uplane_list}        ${index}
    Set Suite Variable     ${s1Uplane_ip}      ${s1Uplane_ip}