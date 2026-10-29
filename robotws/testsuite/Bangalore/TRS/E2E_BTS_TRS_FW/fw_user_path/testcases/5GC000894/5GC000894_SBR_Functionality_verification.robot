*** Settings ***
Documentation
	...		[Procedure]             "The test case is to verify functionality of source based routing"
    ...     [Date]                  "09-05-2025"
    ...     [Author]                "Mansi"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     "Source Based Routing"
    ...     [Feature_ID]            "5GC000894"
    ...     [Validation_status]     "Tested"
    ...     [Validated_TestLine]    "5G-9003"


variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource	${CURDIR}/resources/5GC000894_common_keywords.robot
Library    taf.sw.scout    WITH NAME    scout


Suite Setup                 Pre-conditions for testsuite
Suite Teardown              Post-conditions for testteardown



***Test Cases***
[1][1.0] SBR_Functionality verification
        ${alarms_before_feature}             Verify Alarm
		Perform Commissioning       scf_file=${SBR_functionality}   verify_bts_status=False     timeout=400     alias=default
        Sleep  300
		Call Setup      5g=SBR_cfg:data      parallel=${False}    verify_attach=${False}   attach=${False}    ipv4_or_6=ipv4
        Verify if IPV4 address is configured in gui
        Verify if IPV6 address is configured in gui
		Traffic capture start           capture_device=l2_wireshark    capture_filter=icmp
        Setup Remote Access    remote_device=bts
		Command to execute on board      ping -c 20 -I ${src_ip1} ${dest_ip1}
		Command to execute on board      ping -c 20 -I ${src_ip2} ${dest_ip2}
		Command to execute on board      ping -c 20 -I ${src_ip3} ${dest_ip3}
        Teardown remote Access
        ${pcap_file}=       Traffic capture stop
		Set Suite Variable          ${pcap_file}
		Verify wireshark for source based routing
		Traffic Capture Start 			capture_device=vm_eth3_interface
		verify 'udp' calls and frame length for SA
		verify 'tcp' calls and frame length for SA
		verify calls for SA
		${gtp_msg_pcap_SA} = 		Traffic Capture Stop
		Analyse Pcap        pcap_filename=${gtp_msg_pcap_SA}   filter_file_name=${5GC000894_traffic_filter}        analysis=verify_vlan_UL
		Analyse Pcap        pcap_filename=${gtp_msg_pcap_SA}   filter_file_name=${5GC000894_traffic_filter}        analysis=verify_vlan_DL
        Verify Alarm      prev_alarms=${alarms_before_feature}              check_unexpected_alarms=${True}