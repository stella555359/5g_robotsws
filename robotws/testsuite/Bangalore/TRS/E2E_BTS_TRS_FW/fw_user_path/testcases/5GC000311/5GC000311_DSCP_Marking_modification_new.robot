*** Settings ***
Documentation
	...		[Procedure]				"The test case is verify DSCP check for M-PLANE application"
	...		[QC_Path]				"QC_Path in Test Plan"
	...		[QC_ID]					"QC_ID in Test Lab for reporting"
	...		[Funtion_Hash_Tags]		"M-plane"


Library         ta_emss

variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Suite Setup       Pre-conditions for testsuite
Suite Teardown    Post-conditions for test teardown

*** Test Cases ***
[1][1.0] 5GC000311_DSCP Marking modification

    Perform Commissioning       scf_file=${MPLANE_IPV4_Scf}   verify_bts_status=False     timeout=400     alias=default
    Sleep    400

    Read mplane IP and dscp
    Capture mplane ipv4 packets
    Verify mplane DSCP tagged in wireshark

    Get Random DSCP Value
    Assign new DSCP to Mplane
    Capture mplane ipv4 packets
    Verify mplane new DSCP tagged in wireshark

    Perform site reset
    Capture mplane ipv4 packets
    Verify mplane new DSCP tagged in wireshark

*** Keywords ***

Read mplane IP and dscp
    ${mplane_ipv4}=     Get Parameter   param_path=${mplane_ipv4_ip_moc}
    Set Suite Variable          ${mplane_ipv4}
    ${initial_mplane_dscp}=     Get Parameter   param_path=${mplane_dscp_moc}
    Set Suite Variable          ${initial_mplane_dscp}

Assign new DSCP to Mplane
    Perform Recommissioning     type=param   param_path=${mplane_dscp_moc}    value=${random_dscp}
    ...  skip_parameter_relation_errors=${True}    timeout=300   operation=update
    Sleep   30

Perform upgrade using mplane_ipv4 and verify dscp
    setup oamops    bts_host=${mplane_ipv4}      alias=upgrade_mplane
    Perform software download and update     wft_profile=sbtstrunk_00      package=auto
    ...     activate_sw=true      update_timeout=900
    Sleep   900
    [Teardown]  Teardown oamops     alias=upgrade_mplane

Capture mplane ipv4 packets
    Traffic capture start           capture_device=vm_eth0_interface    capture_filter=tcp
    setup oamops        bts_host=${mplane_ipv4}      alias=mplane
    Teardown oamops         alias=mplane
    ${pcap_file}=       Traffic capture stop
    Set Suite Variable          ${pcap_file}

Verify mplane DSCP tagged in wireshark
    Analyse pcap    pcap_filename=${pcap_file}      analysis=verify_default_mplane_ipv4_dscp
    ...         filter_file_name=${5GC000311_traffic_filter}


Verify mplane new DSCP tagged in wireshark
    Analyse pcap    pcap_filename=${pcap_file}      analysis=verify_changed_mplane_ipv4_dscp
    ...         filter_file_name=${5GC000311_traffic_filter}


Get IPs
	${mplane_ipv4_ip} = 	Get Parameter		param_path=${mplane_ipv4_moc_path}
	Set Suite Variable		${mplane_ipv4_ip}		${mplane_ipv4_ip}
    Sleep   30

Perform site reset
    Reset Bts   req_rat=5g     should_be_onair=True   wait_for=300
    Sleep   300


Perform Mplane Operations and Capture Packets
	[Arguments]     ${file_name_alias}
	Traffic Capture Start		capture_device=l2_wireshark	capture_filter=vlan and (${l2_capture_filter_ipv6_ips})		alias=${file_name_alias}
	Setup Oamops                 bts_host=${mplane_ipv6_ip}		alias=${file_name_alias}
	Setup Remote Access	remote_device=bts_mplane_credentials
	Remote Command Execute		command=dig -b ${mplane_ipv6_ip} ${domain_name}
	Sleep	60
	${pcap_filename}=		Traffic Capture Stop		 alias=${file_name_alias}
	Set Suite Variable	${pcap_filename}	${pcap_filename}

Get Random DSCP Value
    ${random_dscp}=         Evaluate    (random.randrange(0,63))     random
    Set Suite Variable      ${random_dscp}        ${random_dscp}
