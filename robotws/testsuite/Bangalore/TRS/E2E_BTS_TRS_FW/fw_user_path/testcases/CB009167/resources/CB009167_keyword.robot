*** Settings ***
Documentation
...		[Author]     	"Megha"
...		[Maintenance]	"TRS I & V Tools Bangalore Team"

variables	ta_e2e_bts_trs_fw


*** Keywords ***
Collect logs in cloud
    Run Keywords    Setup Oamops    dut=vcu      alias=default   AND     Collect Snapshot
    ...     dut=vcu  operation_timeout=300   alias=default   AND     Run Keyword And Ignore Error    Teardown Oamops
    ...      dut=vcu     alias=default
    Run Keywords    Setup Oamops    dut=vdu	alias=default   AND     Collect Snapshot
    ...     dut=vdu	operation_timeout=600   alias=default   AND     Run Keyword And Ignore Error    Teardown Oamops
    ...      dut=vdu	alias=default

Configure RICSim
    [Documentation]   Configures Near-RT RIC Simulator IP Address
	Run        sudo ip add add ${RIC_gw}/24 dev eth8
        Run        sudo ip add add ${RIC_IPv6}/116 dev eth8

Perform IP Configuration on VM
    [Documentation]   Configures IP Addresses on VM required for Call Setup
    Run        sudo ip add add ${IPv4_1}/24 dev eth3
    Run        sudo ip add add ${IPv4_2}/24 dev eth3
    Run        sudo ip add add ${IPv4_3}/24 dev eth3
    Run        sudo ip add add ${IPv4_4}/24 dev eth3
    Run        sudo ip add add ${IPv4_5}/24 dev eth3
    Run        sudo ip add add ${IPv4_6}/24 dev eth3
    Run        sudo ip add add ${IPv4_7}/24 dev eth3
    Run        sudo ip add add ${IPv4_8}/24 dev eth3
    Run		mkdir /home/ute/CB009167_pcaps

Perform IPsec Configuration on VM
    [Documentation]   Configures IPsec on strongswan
    Run	sudo scp /home/ute/MN/UTE/robotws/testsuite/Bangalore/TRS/E2E_BTS_TRS_FW/fw_user_path/testcases/CB009167/resources/ipsec.secrets /etc
	Run	sudo scp /home/ute/MN/UTE/robotws/testsuite/Bangalore/TRS/E2E_BTS_TRS_FW/fw_user_path/testcases/CB009167/resources/ipsec.conf /etc
	Run	sudo ipsec restart
	Run		mkdir /home/ute/CB009167_pcaps

Perform E2 configuration with IPSec
	Setup Oamops    dut=vcu    alias=vcu
	Perform Commissioning    dut=vcu    scf_file=${CB009167_VRAN_E2_IPSec_config}    timeout=400     alias=vcu
	Sleep	60
	Setup Oamops    dut=vcu    alias=vcu
	Update Cu Psk Configuration	password=Testing@12345	dut=vcu	timeout=30	alias=vcu

Perform E2 configuration with IPV6
	Setup Oamops    dut=vcu    alias=vcu
	Perform Commissioning    dut=vcu    scf_file=${CB009167_VRAN_E2_IPv6_config}    timeout=400     alias=vcu
	#Sleep	400

Verify IPsec status and E2 link status
	Setup Oamops    dut=vcu      alias=vcu
	traffic_capture_start   capture_device=vCU     capture_type=pod    plane_type=['cplane']
	...	pod_names=['po-cpe2-0']    measurement_point=NE_Terminated    timeout=180    alias=vcu
	Perform Call Setup for E2Interface with IPSec
	Setup Oamops    dut=vcu    alias=vcu
	Verify E2LinkStatus     Unlocked    active
	Sleep	30
	traffic_capture_stop   capture_device=vCU      timeout=180  alias=vcu	keep_alias=True
	Sleep   30
        generate_capture_files     capture_device=vCU        timeout=180    alias=vcu
        Sleep   60
	Upload Traffic Capture File     capture_device=vCU      capture_type=plane	plane_type=['cplane']
	...	local_path=${pcaps_dir}    timeout=180  alias=vcu
	Sleep   30
	${cpe2_pcap}=     Run     ls ${pcaps_dir}/ | grep gNB_vCU_1_po-cpe2-0
        set suite variable  ${cpe2_pcap}  ${cpe2_pcap}
    Analyse Pcap    pcap_filename=${pcaps_dir}/${cpe2_pcap}	analysis=sctp_e2ap_success_ipsec	filter_file_name=traffic_filters.json
        Run		rm -rf ${pcaps_dir}/*

Remove RICSim Configuration and verify E2 alarm
	Run        sudo ip add d ${RIC_gw}/24 dev eth8
	Sleep	30
	Wait Until Keyword Succeeds	10 min	1 min	Verify E2 interface alarms	${True}
	Verify E2LinkStatus     Unlocked    inactive
	Perform Recommissioning    dut=vcu  type=delta  delta_file=${E2_Lock_delta}    timeout=400     alias=vcu
	Sleep	30
	Wait Until Keyword Succeeds	5 min	1 min	Verify E2 interface alarms	${False}
	Perform Recommissioning    dut=vcu  type=delta  delta_file=${E2_Unlock_delta}    timeout=400     alias=vcu
	Sleep	30
	Wait Until Keyword Succeeds	5 min	1 min	Verify Alarm    faultid=${faultnum_E2SCTPFail}	should_exist=${True}	dut=vcu	alias=vcu

Remove ipv6 RICSim Configuration and verify E2 alarm
	Run        sudo ip add d ${RIC_IPv6}/116 dev eth8
	Sleep	30
	Wait Until Keyword Succeeds	5 min	1 min	Verify E2 interface alarms	${True}
	Verify E2LinkStatus     Unlocked    inactive
	Setup Oamops    dut=vcu    alias=vcu
	Perform Recommissioning    dut=vcu  type=delta  delta_file=${E2_Lock_delta}    timeout=400     alias=vcu
	Sleep	30
	Wait Until Keyword Succeeds	5 min	1 min	Verify E2 interface alarms	${False}
	Perform Recommissioning    dut=vcu  type=delta  delta_file=${E2_Unlock_delta}    timeout=400     alias=vcu
	Sleep	30
	Wait Until Keyword Succeeds	5 min	1 min	Verify Alarm    faultid=${faultnum_E2SCTPFail}	should_exist=${True}	dut=vcu	alias=vcu

Revertback RICSim Configuration and verify alarm is cleared
	Configure RICSim
	Sleep   30
	Wait Until Keyword Succeeds	5 min	1 min	Verify E2 interface alarms        ${False}
	Verify E2LinkStatus     Unlocked    active

Teardown core configuration and verify E2 alarm
	[Documentation]   When core itself is down, E2 alarm will not be raised as 5G onair should be mandatory for E2 link
	Run Keyword And Ignore Error	Perform Call TearDown for E2Interface
	Sleep	120
	Wait Until Keyword Succeeds	3 min	1 min	Verify E2LinkStatus     Unlocked    inactive
	Wait Until Keyword Succeeds	5 min	1 min	Verify E2 interface alarms	${False}

Perform Call Setup for E2Interface with ipv6
    Run Keyword And Ignore Error	Call Setup	dut=vcu	5g=5g_basic_ipv6_RIC_Config:data	parallel=${False}	alias=vcu
    ...     verify_attach=${False}	attach=${False}		timeout=300

Perform Call Setup for E2Interface with IPSec
    Run Keyword And Ignore Error	Call Setup  5g=5g_basic_RIC_Config_IPSec:data      parallel=${False}
    ...     verify_attach=${False}    attach=${False}     timeout=300

Perform Call TearDown E2Interface
    Call Teardown   5g=5g_basic_RIC_Config:data

Verify ipv6 E2 link status
	Setup Oamops    dut=vcu    alias=vcu
	traffic_capture_start   capture_device=vCU     capture_type=pod    plane_type=['cplane']     pod_names=['po-cpe2-0']
	...	measurement_point=NE_Terminated    timeout=180    alias=vcu
	Perform Call Setup for E2Interface with ipv6
	Verify E2 interface alarms        ${False}
	Verify E2LinkStatus     Unlocked    active
	traffic_capture_stop   capture_device=vCU      timeout=180  alias=vcu	keep_alias=True
	Sleep   30
        generate_capture_files     capture_device=vCU        timeout=180    alias=vcu
        Sleep   60
	Upload Traffic Capture File     capture_device=vCU      capture_type=plane      plane_type=['cplane']
	...	local_path=${pcaps_dir}    timeout=180  alias=vcu
	Sleep   30
	${cpe2_ipv6_pcap}=     Run     ls ${pcaps_dir}/ | grep gNB_vCU_1_po-cpe2-0
        set suite variable  ${cpe2_ipv6_pcap}  ${cpe2_ipv6_pcap}
	Analyse Pcap    pcap_filename=${pcaps_dir}/${cpe2_ipv6_pcap}        analysis=sctp_e2ap_success	filter_file_name=traffic_filters.json
	Run		rm -rf ${pcaps_dir}/*

Verify E2 interface alarms
    [Arguments]      ${status}
    #Verify Alarm    faultid=${faultnum_E2SCTPFail}   should_exist=${status}	dut=vcu    alias=vcu
    Verify Alarm    faultid=${faultnum_E2SCTPBroken}   should_exist=${status}	dut=vcu    alias=vcu

Verify E2LinkStatus
    [Arguments]      ${AdminStatus}  ${linkStatus}
    ${e2LinkAdminStatus}=     Get Parameter   param_path=${adminStatus_moc}	dut=vcu    alias=vcu
    Should Be Equal     ${e2LinkAdminStatus}   ${AdminStatus}
    ${E2_link_status}=   Get Parameter   param_path=${e2_moc_path}	dut=vcu    alias=vcu
    Should Be Equal     ${E2_link_status}   ${linkStatus}

Reset vcu and Verify alarm persistance
	Setup Oamops    dut=vcu    alias=vcu
	Reset     operation=reset_bts    rat=5g     dut=vcu    alias=vcu
	...	should_be_onair=${False}     verify_bts=${True}
	Sleep   120
	Setup Oamops    dut=vcu    alias=vcu
	Setup Oamops    dut=dbts    alias=vdu
	Verify Bts Status   should_be_onair=${True}		dut=dbts	alias=vdu
	Wait Until Keyword Succeeds	5 min	1 min	Verify Alarm    faultid=${faultnum_E2SCTPFail}	should_exist=${True}	dut=vcu	alias=vcu
	Verify E2LinkStatus     Unlocked    inactive

Disable Ipsec and verify E2 link status
	Perform Recommissioning    dut=vcu  type=delta  delta_file=${E2_IPSEC_disable_delta}	timeout=400     alias=vcu
	Sleep	30
	Run	sudo ipsec restart
	Setup Oamops    dut=vcu    alias=vcuvcu
	traffic_capture_start   capture_device=vCU     capture_type=pod    plane_type=['cplane']
	...	pod_names=['po-cpe2-0']    measurement_point=Transport_Interface    timeout=180    alias=vcuvcu
	Sleep	30
	Verify E2LinkStatus     Unlocked    active
	Verify E2 interface alarms        ${False}
	traffic_capture_stop   capture_device=vCU      timeout=180  alias=vcuvcu	keep_alias=True
	Sleep   30
        generate_capture_files     capture_device=vCU        timeout=180    alias=vcuvcu
        Sleep   60
	Upload Traffic Capture File     capture_device=vCU      capture_type=plane
	...	plane_type=['cplane']     local_path=${pcaps_dir}    timeout=180  alias=vcuvcu
	Sleep   30
	${E2_success}=     Run     ls ${pcaps_dir}/ | grep gNB_vCU_1_po-cpe2-0
    set suite variable  ${E2_success}  ${E2_success}
    Analyse Pcap    pcap_filename=${pcaps_dir}/${E2_success}        analysis=e2ap_noesp	filter_file_name=traffic_filters.json
	Run		rm -rf ${pcaps_dir}/*

Change RICSCTPPort and check E2 alarm with IPsec status
	Run Keyword And Ignore Error	Perform Recommissioning    dut=vcu  type=delta	delta_file=${E2_wrong_SCTPPort_delta}
	...	skip_parameter_relation_errors=${True}	force_reset=${True}	reset_needed=${True}	auto_lock_cells=${True}	timeout=300	alias=vcu
	Sleep	300
	Setup Oamops    dut=vcu    alias=vcu
	Verify E2LinkStatus     Unlocked    inactive
	Wait Until Keyword Succeeds	9 min	1 min	Verify Alarm    faultid=${faultnum_E2SCTPFail}	should_exist=true	dut=vcu	alias=vcu
	Run Keyword And Ignore Error	Perform Recommissioning    dut=vcu  type=delta	delta_file=${E2_Correct_SCTPPort_delta}
	...	skip_parameter_relation_errors=${True}	force_reset=${True}	reset_needed=${True}	auto_lock_cells=${True}	timeout=300	alias=vcu
	Sleep	300
	Wait Until Keyword Succeeds	9 min	1 min	Verify E2LinkStatus     Unlocked    active
	Wait Until Keyword Succeeds	5 min	1 min		Verify E2 interface alarms        ${False}

Lock and Unlock E2 link and verify E2
	Perform Recommissioning    dut=vcu  type=delta  delta_file=${E2_Lock_delta}    timeout=400     alias=vcu
	Sleep	30
	Setup Oamops    dut=vcu    alias=vcucu
	traffic_capture_start   capture_device=vCU     capture_type=pod    plane_type=['cplane']
	...	pod_names=['po-cpe2-0']    measurement_point=NE_Terminated    timeout=180    alias=vcucu
	Perform Recommissioning    dut=vcu  type=delta  delta_file=${E2_Unlock_delta}	timeout=400     alias=vcu
	Verify E2LinkStatus     Unlocked    active
	Verify E2 interface alarms        ${False}
	traffic_capture_stop   capture_device=vCU      timeout=180  alias=vcucu	keep_alias=True
	Sleep   30
        generate_capture_files     capture_device=vCU        timeout=180    alias=vcucu
        Sleep   60
	Upload Traffic Capture File     capture_device=vCU      capture_type=plane      plane_type=['cplane']
	...	local_path=${pcaps_dir}    timeout=180  alias=vcucu
	Sleep   30
	${cpe2_lock_unlock_pcap}=     Run     ls ${pcaps_dir}/ | grep gNB_vCU_1_po-cpe2-0
        set suite variable  ${cpe2_lock_unlock_pcap}  ${cpe2_lock_unlock_pcap}
	Analyse Pcap    pcap_filename=${pcaps_dir}/${cpe2_lock_unlock_pcap}        analysis=sctp_e2ap_success	filter_file_name=traffic_filters.json
	Run		rm -rf ${pcaps_dir}/*

Get Near RT RIC IPAddress
    ${nrNearRTRICIPAddress}=     Get Parameter   param_path=${nrNearRTRICIPAddress_moc}
    Set Suite Variable      ${nrNearRTRICIPAddress}

Get Near RT RIC SCTPPort
    ${nrNearRTRICSCTPPort}=     Get Parameter   param_path=${nrNearRTRICSCTPPort_moc}
    Set Suite Variable      ${nrNearRTRICSCTPPort}

Get e2Plane ipv4Addresses
    ${e2Plane_ipV4Address}=     Get Parameter   param_path=${e2Plane_ipV4AddressDN1_moc}:localIpAddr
    Set Suite Variable      ${e2Plane_ipV4Address}

Get e2Plane ipv6Addresses
    ${e2Plane_ipV6Address}=     Get Parameter   param_path=${e2Plane_ipV6AddressDN1_moc}:localIpAddr
    Set Suite Variable      ${e2Plane_ipV6Address}

Perform Call TearDown for E2Interface
    Call Teardown   5g=5g_basic_RIC_Config:data
	Run     cd /opt/iphy/latest/ ; sudo killall egate edaemon

Modify cplane DSCP value
    	Setup Oamops    dut=vcu      alias=vcu
	traffic_capture_start   capture_device=vCU     capture_type=pod    plane_type=['cplane']
	...	pod_names=['po-cpe2-0']    measurement_point=NE_Terminated    timeout=180    alias=vcu
	Perform Recommissioning    dut=vcu  type=delta  delta_file=vCU_CPlane_DSCP_E2.xml    timeout=400     alias=vcu
	Sleep	30
	traffic_capture_stop   capture_device=vCU      timeout=180  alias=vcu	keep_alias=True
	Sleep   30
        generate_capture_files     capture_device=vCU        timeout=180    alias=vcu
        Sleep   40
	Upload Traffic Capture File     capture_device=vCU      capture_type=plane      plane_type=['cplane']
	...	local_path=${pcaps_dir}    timeout=180  alias=vcu
	Sleep   30
	${cpe2_DSCP_pcap}=     Run     ls ${pcaps_dir}/ | grep gNB_vCU_1_po-cpe2-0
        set suite variable  ${cpe2_DSCP_pcap}  ${cpe2_DSCP_pcap}
	Analyse Pcap    pcap_filename=${pcaps_dir}/${cpe2_DSCP_pcap}        analysis=sctp_e2ap_Mod_DSCP	filter_file_name=traffic_filters.json
	Run		rm -rf ${pcaps_dir}/*

Keywords To Run At End
    Run     cd /opt/iphy/latest/ ; sudo killall egate edaemon
    Run		rm -rf /home/ute/CB009167_pcaps/*
    Configure RICSim
    Run Keyword And Ignore Error	traffic_capture_stop   capture_device=vCU      timeout=180  alias=vcu
