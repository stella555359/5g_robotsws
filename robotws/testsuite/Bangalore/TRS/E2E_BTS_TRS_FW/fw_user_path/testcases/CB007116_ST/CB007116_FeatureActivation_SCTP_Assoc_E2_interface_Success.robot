*** Settings ***
Documentation
...	    [Procedure]				"The test case performs commissioning and verifies config of CB007116 parameters. SCTP,
...                              E2AP procedures also verified."
...	    [Date]					"13-07-2022"
...	    [Author]				"Sharavathi & Vishal"
...	    [Feature_ID] 			"CB007116"
...	    [Maintenance]			"TRS I & V Tools Bangalore Team"
...	    [Funtion_Hash_Tags] 	"E2LINK_RIC"
...	    [Validated_TestLine] 	"CLASSICAL_5G - ASIB, ASIL, ASIK, ASOE topologies"
...	    [Config_Comments] 		"5G classical mode SA config with IPv4, SA call issues so just capturing packets between RIC & BTS"
...	    [Precondition] 			"BTS should be operational and on Air with NR RAT"
...	    [QC_Path]               "QC_Path in Test Plan"
...	    [QC_ID]					"QC_ID in Test Lab for reporting"

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/CB007116_utilities.robot

Suite Setup		Run Keywords	Suite Setup Preconditions
...             AND		Setup Oamops
Suite Teardown	Run Keywords	Suite Teardown Postconditions
...             AND		Teardown Oamops

*** Test Cases ***
[1]CB007116_FeatureActivation_SCTP_Assoc_E2_interface_Success
    Perform Commissioning       scf_file=${Full_Configuration}   verify_bts_status=False     timeout=400     alias=default
    Sleep    300

    Setup Ems  config_device=netact   alias=lab1042
    Cm Upload   config_device=netact   alias=lab1042

    Verify Bts Status   should_be_onair=${True}
    Traffic Capture Start   capture_device=bts      alias=on_bts
    Sleep    20
    ${E2AP_Msg_pcap}=   Traffic Capture Stop        mode=file     timeout=120       alias=on_bts
    Analyse Pcap        pcap_filename=${E2AP_Msg_pcap}   filter_file_name=${CB007116_traffic_filters}        analysis=sctp_e2ap_success
    Verify E2 interface alarms        ${False}
    Verify E2LinkStatus     Unlocked    active

    Modify cplane DSCP value
    Traffic Capture Start   capture_device=bts      alias=bef_reset
    Sleep   60
    ${E2AP_modified_DSCP}=   Traffic Capture Stop       alias=bef_reset
    Analyse Pcap        pcap_filename=${E2AP_modified_DSCP}   filter_file_name=${CB007116_traffic_filters}
    ...     analysis=sctp_e2ap_Mod_DSCP

    Reset Bts        verify_bts=False    req_rat=5g        should_be_onair=False    wait_for=300
    Verify Bts Status   should_be_onair=${True}
    Traffic Capture Start   capture_device=bts      alias=aft_reset
    Sleep   30
    ${E2AP_Msg_after_reboot_pcap}=      Traffic Capture Stop       alias=aft_reset
    Analyse Pcap        pcap_filename= ${E2AP_Msg_after_reboot_pcap}     filter_file_name=${CB007116_traffic_filters}
    ...     analysis=sctp_e2ap_Mod_DSCP
    Verify E2 interface alarms        ${False}
    Verify E2LinkStatus     Unlocked    active

    [Teardown]    Run Keyword     Tear Traffic Captures and NMS Down
