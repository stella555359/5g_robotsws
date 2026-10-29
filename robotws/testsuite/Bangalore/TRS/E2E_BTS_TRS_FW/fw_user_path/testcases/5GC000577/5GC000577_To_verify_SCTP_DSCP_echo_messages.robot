*** Settings ***
Documentation
    ...     [Procedure]             "The test case is to validate 5G call functionality along with DSCP values for cplane
    ...     and GTPU error indication messages"
    ...     [Date]                  "27-04-20"
    ...     [Author]                "Pavithra C"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     "SCTP,SCTP abort"
    ...     [Feature_ID]            "5GC000577"
    ...     [Validation_status]     "validated"
    ...     [Validated_TestLine]    "5G-9010"

variables       ta_e2e_bts_trs_fw
Resource    ${CURDIR}/../resources/common_keywords.robot

Suite Setup     Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown  Run Keywords    Suite Teardown Postconditions
...     AND     Teardown Oamops

***Test Cases***

[1][1.0] TRS_5GC000577_ASIK_To_verify_SCTP_DSCP_echo_messages
    [Documentation]     The test case is to validate 5G call functionality along with DSCP values for cplane and GTPU error indication messages
    Perform Commissioning       scf_file=${basic_asik}   verify_bts_status=False     timeout=600
    Sleep    300
    Perform Recommissioning     type=param      rat=lte     param_path=MRBTS-1/MNL-1/MNLENT-1/FEATCADM-1:actFaultSignature   operation=update
    ...     value=true      timeout=600
    Read 5G NSA IPv4 IPv6 Parameters
    @{rats}=  Split String  ${cplane_rats}
    FOR    ${rat}    IN    @{rats}
       Run Keyword If     "${rat}" == "5g"    Verify SCTP and echo message for 5g
    END
    [Teardown]     Teardown 5g call

*** Keywords ***

Read BTS Parameters
    [Documentation]     This keyword reads the configured value for cplane IPs based on the rat environment.

    Run Keyword If      '5g' in ${rat_env} or 'SRAN_5G' in ${rat_env} and 'NSA' in ${bts_hw_version}    Read 5G NSA IPv4 IPv6 Parameters
    #Run Keyword If      '5g' in ${rat_env} or 'SRAN_5G' in ${rat_env} and 'SA' in ${bts_hw_version}     Read 5G SA IPv4 IPv6 Parameters
    Run Keyword If      'LTE' in ${rat_env} or 'SRAN_5G' in ${rat_env}      Read LTE IPv4 IPv6 Parameters
    Run Keyword If      'SRAN' in ${rat_env} or 'SRAN_5G' in ${rat_env}     Read WCDMA IPv4 IPv6 Parameters
    Run Keyword If      'SRAN' in ${rat_env} or 'SRAN_5G' in ${rat_env}     Read GSM IPv4 IPv6 Parameters
    ${cplane_rats}=     Set Variable If
    ...     'sran_5g' in ${rat_env}     5g,lte,wcdma,gsm
    ...     '5g' in ${rat_env}          5g
    ...     'sran' in ${rat_env}        lte,wcdma,gsm
    ...     'lte' in ${rat_env}         lte
    Set Suite Variable      ${cplane_rats}       ${cplane_rats}
Read 5G NSA IPv4 IPv6 Parameters
    ${5g_x2u} =             Get Parameter   rat=common      param_path=${5g_x2u_ip_moc_path}
    ${5g_x2c} =             Get Parameter   rat=common      param_path=${5g_x2c_ip_moc_path}
    ${5g_s1u} =             Get Parameter   rat=common      param_path=${5g_s1u_ip_moc_path}

    Set Suite Variable  ${5g_x2u}       ${5g_x2u}
    Set Suite Variable  ${5g_x2c}       ${5g_x2c}
    Set Suite Variable  ${5g_s1u}       ${5g_s1u}

    ${initial_cplane_dscp}=      Get Parameter     rat=5g       param_path=${5g_cplane_dscp_path}
    Set Suite Variable      ${initial_cplane_dscp}      ${initial_cplane_dscp}

Perform 5G call for uplink traffic
    [Documentation]     This keyword will establish x2-link and send uplink traffic.
    Call Setup      5g=device1:data  parallel=${False}  verify_attach=${False}  ipv4_or_6=ipv4  attach=${False}   timeout=600
    Sleep   5
    #Verify Bts Status     req_rat=5g   should_be_onair=${True}
    Call Start      5g=device1:data  profile=udp_ul
    #Call Start      profile=udp_ul
    Sleep   15
    Run Keyword And Ignore Error    Call Stop  5g=device1:data  profile=udp_ul
    [Teardown]      Call Teardown   5g=device1:data

Perform 5G call for downlink traffic
    [Documentation]     This keyword will send downlink traffic.
    Call Start      5g=device1:data  profile=udp_dl
    #Call Start      profile=udp_dl
    Sleep   15
    Run Keyword And Ignore Error    Call Stop  5g=device1:data  profile=udp_dl
    [Teardown]      Call Teardown   5g=device1:data

Command to execute on airphone
    [Arguments]      ${command}
    Setup Remote Access    remote_device=airphone
    Run Keyword And Ignore Error    Remote Command Execute      command=${command}
    [Teardown]      Teardown remote Access

Traffic capture and 5G call for uplink and downlink traffic
    Traffic capture start           capture_device=lmp_pc_all_interface
    Setup Remote Access    remote_device=bts
    Perform 5G call for uplink traffic
    #Perform 5G call for downlink traffic
    [Teardown]      Teardown remote Access
    ${pcap_file}=       Traffic capture stop
    Set Suite Variable     ${pcap_file}

Verify wireshark for uplink traffic
    Analyse pcap    pcap_filename=${pcap_file}      analysis=verify_uplink_traffic       filter_file_name=${5GC000577_traffic_filter}

Verify wireshark for downlink traffic
    Analyse pcap    pcap_filename=${pcap_file}      analysis=verify_downlink_traffic       filter_file_name=${5GC000577_traffic_filter}

Verify SCTP source port for 5g
    Analyse pcap    pcap_filename=${pcap_file}      analysis=verify_source_port_for_5g     filter_file_name=${5GC000577_traffic_filter}

Verify SCTP destination port for 5g
    Analyse pcap    pcap_filename=${pcap_file}      analysis=verify_destination_port_for_5g   filter_file_name=${5GC000577_traffic_filter}

Verify Payload protocol identifier for 5g
    Analyse pcap    pcap_filename=${pcap_file}      analysis=verify_payload_protocol_identifier_for_5g
    ...    filter_file_name=${5GC000577_traffic_filter}

Verify SCTP source port for lte
	Analyse pcap    pcap_filename=${pcap_file}      analysis=verify_source_port_for_lte     filter_file_name=${5GC000577_traffic_filter}

Verify SCTP destination port for lte
    Analyse pcap    pcap_filename=${pcap_file}      analysis=verify_destination_port_for_lte   filter_file_name=${5GC000577_traffic_filter}

#Verify Payload protocol identifier for lte
#    Analyse pcap    pcap_filename=${pcap_file}      analysis=verify_payload_protocol_identifier_for_lte
#    ...    filter_file_name=${5GC000577_traffic_filter}

Verify wireshark for Initial cplane DSCP value in SCTP
    Analyse pcap    pcap_filename=${pcap_file}      analysis=verify_initial_cplane_dscp_sctp         filter_file_name=${5GC000577_traffic_filter}

Verify wireshark for modified cplane DSCP value in SCTP
    Analyse pcap    pcap_filename=${pcap_file}      analysis=verify_modified_cplane_dscp_sctp         filter_file_name=${5GC000577_traffic_filter}

Verify wireshark for SCTP abort message
    Analyse pcap    pcap_filename=${pcap_file}      analysis=verify_sctp_abort       filter_file_name=${5GC000577_traffic_filter}

Change cplane dscp
        FOR   ${i}   IN RANGE   10
            ${changed_cplane_dscp}=         Evaluate    random.choice(range(0, 64))  random
            Set Suite Variable      ${changed_cplane_dscp}      ${changed_cplane_dscp}
            Exit For Loop if     ${changed_cplane_dscp} != ${initial_cplane_dscp}
        END
        Perform Recommissioning     type=param      rat=5g    param_path=${cplane_dscp_moc}  operation=update    value=${changed_cplane_dscp}
        ...     timeout=300

Teardown 5g call
    #Run Keyword And Ignore Error    Call Stop  5g=airphone:data  profile=udp_ul
	#Run Keyword And Ignore Error    Call Stop  5g=airphone:data  profile=udp_ul
    #Run Keyword And Ignore Error    Call Stop  5g=airphone:data  profile=udp_dl
    #Call Teardown   5g=airphone:data
    Run Keyword And Ignore Error    Traffic capture stop
    Run    sudo killall egate edaemon

SCTP abort scenario teardown
    Run Keyword And Ignore Error    Teardown remote Access
    Run Keyword And Ignore Error    Traffic capture stop
    Run    sudo iptables -D OUTPUT -p sctp -j DROP

Simulated SCTP ABORT Scenario
    [Documentation]    This keyword will SCTP abort scenario
    Traffic capture start           capture_device=lmp_pc_all_interface
    Setup Remote Access    remote_device=bts
#    Call Setup      5g=device1:data  parallel=${False}  verify_attach=${False}  ipv4_or_6=ipv4
    Sleep   5
    Run    sudo iptables -A OUTPUT -p sctp -j DROP
    Sleep   300
    Teardown remote Access
    ${pcap_file}=       Traffic capture stop
    Set Suite Variable     ${pcap_file}
    Run    sudo iptables -D OUTPUT -p sctp -j DROP
    [Teardown]     SCTP abort scenario teardown

Verify SCTP and echo message for 5g
    ${initial_cplane_dscp}=      Get Parameter     rat=5g       param_path=${cplane_dscp_moc}
    Set Suite Variable      ${initial_cplane_dscp}      ${initial_cplane_dscp}
    Traffic capture and 5G call for uplink and downlink traffic
    Verify wireshark for Initial cplane DSCP value in SCTP
	Verify SCTP source port for 5g
    Verify SCTP destination port for 5g
    Verify Payload protocol identifier for 5g
#    Verify wireshark for uplink traffic
    #Verify wireshark for downlink traffic
    ######Modify C-plane DSCP value and check value in pcap
    Change cplane dscp
    Traffic capture and 5G call for uplink and downlink traffic
    Verify wireshark for modified cplane DSCP value in SCTP
    Simulated SCTP ABORT Scenario
    Verify wireshark for SCTP abort message