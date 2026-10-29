*** Settings ***
Documentation
...            [Author]         "Sahana T C"
...            [Maintenance]    "TRS I & V Tools Bangalore Team"

Variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../../resources/common_keywords.robot

***keywords***

Verify Drop Counters
    Start Ip traffic capture point A file mode       oam_device
    Pm Counters Start    dut=bts     analysis=verify_drop
    ...     counter_analysis_file=${counter_analysis_file_name}     pm_interval=5    alias=default
    Log    Send invalid uplane packets with wrong src udp port
    Traffic Start   profile=scapy_initiated_uplane     alias=default1
    Verify PM Counters    dut=bts    analysis=verify_drop
    ...     counter_analysis_file=${counter_analysis_file_name}  pm_interval=5    alias=default
    Stop Ip traffic capture in file mode
    Analyse Pcap    pcap_filename=${pcap_file}   analysis=uplane

Scapy initiated traffic
    Log     Start sending traffic from scapy to u-m-c plane ips with ipsec enabled
    Start Ip traffic capture point A file mode       oam_device
    Traffic Setup           device=SMO         alias=default1
    Traffic Start   profile=scapy_initiated_mplane     alias=default1
    Traffic Start   profile=scapy_initiated_mplane_v6     alias=default1
    Traffic Start   profile=scapy_initiated_cplane     alias=default1
    Traffic Start   profile=scapy_initiated_cplane_v6     alias=default1
    Traffic Start   profile=scapy_initiated_uplane_v6     alias=default1
    Traffic Start   profile=scapy_initiated_uplane_valid     alias=default1
    Stop Ip traffic capture in file mode
    Analyse Pcap    pcap_filename=${pcap_file}   analysis=mplane
    Analyse Pcap    pcap_filename=${pcap_file}   analysis=mplane_v6
    Analyse Pcap    pcap_filename=${pcap_file}   analysis=uplane_valid
    Analyse Pcap    pcap_filename=${pcap_file}   analysis=uplane_v6
    Analyse Pcap    pcap_filename=${pcap_file}   analysis=cplane
    Analyse Pcap    pcap_filename=${pcap_file}   analysis=cplane_v6

Install BTS Certificates
    Certificate Configure    operation=install_certificate    cert_file=${IP_BTSCertp12}    cert_type=BtsTrustChain
    ...     cert_format=P12     password=${IP_BTSCertpass}
    BuiltIn.Sleep    20

Start Ip traffic capture point A file mode
    [Arguments]       ${capture_device}      ${uplane_val}=True          ${alias}=default
    Traffic Capture Start     capture_device=${capture_device}    mode=file     measurement_point=NE_Terminated
    ...   uplane_capturing=${uplane_val}    timeout=120    alias=${alias}
    BuiltIn.Sleep    10

Stop Ip traffic capture in file mode
    [Arguments]        ${alias}=default
    ${pcap_file}=  Traffic Capture Stop   mode=file   alias=${alias}  timeout=120
    Set Suite Variable     ${pcap_file}