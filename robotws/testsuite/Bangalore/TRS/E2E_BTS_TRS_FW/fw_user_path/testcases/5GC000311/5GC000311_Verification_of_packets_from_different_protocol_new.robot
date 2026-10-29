*** Settings ***
Documentation
...     [Documentation]
...     [Author]                        "Nandini P"
...     [Function_Hash_Tags]            "IPV6_Mplane"


Library         ta_emss
Variables       ta_e2e_bts_trs_fw

Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot

#Suite Setup     Setup Oamops
#Suite Teardown  Teardown Oamops

Suite Setup       Pre-conditions for testsuite
Suite Teardown    Post-conditions for test teardown



***Test Cases***
[1][1.0] 5GC000311_Verification of packets for different protocols

        Perform Commissioning       scf_file=${MPLANE_IPV4_Scf_311_protocols}   verify_bts_status=False
        ...     timeout=400     alias=default
        Sleep    400
        Read mplane IP and dscp
        Capture mplane ipv4 packets
        Verify wireshark for default mplane ipv4 packets
        Perform NTP operation and verify in wireshark    ${traffic_3}
        Perform cmp operation and verify in wireshark    ${traffic_1}
#        Perform site reset
        Perform ldap operation and verify in wireshark  ${traffic_2}

        [Teardown]      Keywords to run at end

***Keywords***
Keywords to run at end
        Run Keyword and ignore error        Traffic capture stop
        Change Ethernet port security       enable=${False}   timeout=120
        Run Keyword and ignore error       Traffic Capture Stop   mode=file  timeout=100
Read mplane IP and dscp
        ${mplane_ipv4}=     Get Parameter   param_path=${mplane_ipv4_ip_moc}
        Set Suite Variable          ${mplane_ipv4}
        ${initial_mplane_dscp}=     Get Parameter   param_path=${mplane_dscp_moc}
        Set Suite Variable          ${initial_mplane_dscp}

Verify wireshark for default mplane ipv4 packets
        Analyse pcap    pcap_filename=${pcap_file}      analysis=verify_default_mplane_ipv4_dscp
        ...     filter_file_name=${5GC000311_traffic_filter}


Capture mplane ipv4 packets
        Traffic capture start           capture_device=vm_eth0_interface    capture_filter=tcp
        setup oamops        bts_host=${mplane_ipv4}      alias=mplane
        Teardown oamops         alias=mplane
        Sleep   120
        ${pcap_file}=       Traffic capture stop
        Set Suite Variable          ${pcap_file}

Perform NTP operation and verify in wireshark
        [Arguments]     ${pcap_1}
        Traffic Capture Start     capture_device=oam_device   mode=file     measurement_point=NE_Terminated
        ...     uplane_capturing=True     timeout=120    alias=${pcap_1}
        Perform Recommissioning     type=delta      rat=5g     delta_file=${delta_Addition_NTP}    timeout=300
        Sleep   300
        ${filename_A}=  Traffic Capture Stop   mode=file   timeout=100  alias=${pcap_1}
        Analyse Pcap        pcap_filename=${filename_A}     analysis=verify_default_ntp_mplane_ipv4_dscp
        ...     filter_file_name=${5GC000311_traffic_filter}


Perform cmp operation and verify in wireshark
        [Arguments]     ${pcap_1}
        Traffic Capture Start     capture_device=oam_device   mode=file     measurement_point=NE_Terminated
        ...     uplane_capturing=True     timeout=120    alias=${pcap_1}
        Certificate configure        operation=install_cmp_certificate
        Sleep   400
        ${filename_A}=  Traffic Capture Stop   mode=file   timeout=100  alias=${pcap_1}
        Analyse Pcap        pcap_filename=${filename_A}     analysis=verify_default_cmp_mplane_ipv4_dscp
        ...     filter_file_name=${5GC000311_traffic_filter}

Perform ldap operation and verify in wireshark
        [Arguments]     ${pcap_1}
        Traffic Capture Start     capture_device=oam_device   mode=file     measurement_point=NE_Terminated
        ...     uplane_capturing=True     timeout=120    alias=${pcap_1}
        Sleep   60
        Certificate configure        operation=update_certificate_revocation_list   timeout=300
        Sleep   400
        Run     ping -w 5 192.168.255.129
        ${filename_A}=  Traffic Capture Stop   mode=file   timeout=100  alias=${pcap_1}
        Analyse Pcap        pcap_filename=${filename_A}     analysis=verify_default_ldap_mplane_ipv4_dscp
        ...     filter_file_name=${5GC000311_traffic_filter}


Perform site reset
    Reset Bts   req_rat=5g     should_be_onair=True   wait_for=300
    Sleep   300


Perform cmp and ldap operation
        [Arguments]     ${pcap_1}
        Traffic Capture Start     capture_device=oam_device   mode=file     measurement_point=NE_Terminated
        ...   uplane_capturing=True     timeout=120    alias=${pcap_1}
        Certificate configure        operation=install_cmp_certificate
        Sleep   400
        Certificate configure        operation=update_certificate_revocation_list
        Sleep   400
        ${filename_A}=  Traffic Capture Stop   mode=file   timeout=100  alias=${pcap_1}
        Analyse Pcap        pcap_filename=${filename_A}     analysis=verify_default_cmp_mplane_ipv4_dscp
        ...         filter_file_name=${5GC000311_traffic_filter}
        Analyse Pcap        pcap_filename=${filename_A}     analysis=verify_default_ldap_mplane_ipv4_dscp
        ...          filter_file_name=${5GC000311_traffic_filter}





Change mplane dscp value
    Perform Recommissioning     type=param      rat=5g     param_path=${mplane_dscp_moc}  operation=update
    ...     ${changed_mplane_dscp}     timeout=300
    Sleep   900



Change mplane dscp
#randomize DSCP
    FOR   ${i}   IN RANGE   10
        ${changed_mplane_dscp}=         Evaluate    random.choice(range(0, 64))  random
        Set Suite Variable      ${changed_mplane_dscp}      ${changed_mplane_dscp}
        Exit For Loop if     ${changed_mplane_dscp}!=${initial_mplane_dscp}
    END
    Perform Recommissioning     type=param      rat=5g     param_path=${mplane_dscp_moc}  operation=update
    ...     value=${changed_mplane_dscp}     timeout=300
    Sleep   900


