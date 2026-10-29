** Settings ***
Documentation
...     [Documentation]
...     [Author]                        "Nandini P"
...     [Function_Hash_Tags]            "IPV6_Mplane"


variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Suite Setup       Pre-conditions for testsuite
Suite Teardown    Post-conditions for test teardown

***Test Cases***
[1][1.0] 5GC000311_Verify the gNB upgrade by M plane IP login
    Configure Mplane IP via scf
    Read mplane IP and dscp
    Perform upgrade using mplane_ipv4
    Capture mplane ipv6 packets
    Verify wireshark for mplane ipv6 packets

***Keywords***
Configure Mplane IP via scf
    Perform Commissioning       scf_file=${MPLANE_IPV6_Scf}   verify_bts_status=False
    ...     timeout=400     alias=default
    Sleep    600
Read mplane IP and dscp
    ${mplane_ipv6}=     Get Parameter   param_path=${mplane_ipv6_ip_moc}
    Set Suite Variable          ${mplane_ipv6}
    ${initial_mplane_dscp}=     Get Parameter   param_path=${mplane_dscp_moc}
    Set Suite Variable          ${initial_mplane_dscp}
Perform upgrade using mplane_ipv4
    setup oamops    bts_host=${mplane_ipv6}      alias=upgrade_mplane
    Perform software download and update     wft_profile=sbtstrunk_00      package=auto
    ...     activate_sw=true    update_timeout=900
    Sleep   900
    [Teardown]  Teardown oamops     alias=upgrade_mplane
Capture mplane ipv6 packets
    Traffic capture start           capture_device=vm_eth3_interface    capture_filter=tcp
    setup oamops        bts_host=${mplane_ipv6}      alias=mplane
    Teardown oamops         alias=mplane
    ${pcap_file}=       Traffic capture stop
    Set Suite Variable          ${pcap_file}
Verify wireshark for mplane ipv6 packets
    Analyse pcap    pcap_filename=${pcap_file}      analysis=verify_mplane_ipv6_dscp
    ...         filter_file_name=${5GC000311_traffic_filter}
Verify wireshark for changed mplane ipv4 packets
    Analyse pcap    pcap_filename=${pcap_file}      analysis=verify_changed_mplane_ipv4_dscp
    ...         filter_file_name=${5GC000311_traffic_filter}


