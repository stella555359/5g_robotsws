*** Settings ***
Documentation
...     [Procedure]             "The test case is planned to validate IPv4 Ingress rate limit for ICMP packets for M/U/C/S planes"
...     [Date]                  "17-12-22"
...     [Author]                "Lata Patil"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"
...     [Funtion_Hash_Tags]     "FIREWALL, COUNTERS"
...     [Feature_ID]            "RP000366,5G000265,CNI40152-A,CB007672,SR002103"
...     [Validation_status]     "Validated and Passed"
...     [Validated_TestLine]    "SBTS-2003"
...     [Config_Comments]       "This script requires SCF loading with ipfilteringinterval=15min,icmpresponseenabled=true,ethernetportenabled=true"

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/packet_generation_verification_common_keywords.robot



Suite Setup     Run Keywords        Suite Setup Preconditions        AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions       AND     Teardown Oamops

*** Variables ***
${time}     5min

*** Test Cases ***

[1]CB005750-5G-EBAJ-SyVe 5GC001577-KA-5GC000265_Stateful_packet_filtering_for_DU_initiated_traffic_flows_IPv4
    5GC001526-FA-5GC000265_Stateful_packet_filtering_for_DU_initiated_traffic_flows_IPv4

*** Keywords ***

5GC001526-FA-5GC000265_Stateful_packet_filtering_for_DU_initiated_traffic_flows_IPv4
    Perform Recommissioning        type=param           param_path=PMTNLINT-1:ipFilteringInterval     operation=update     value=${time}    timeout=60
    Traffic Setup       device=device_1
    ${mplane_ipv4} =    Get Parameter   param_path=${mplane_ipv4_moc_path}
    Set Suite Variable  ${ipv4_dest}    ${mplane_ipv4}
    ${ipv4_src} =    Get Parameter   param_path=MRBTS-3927/TNLSVC-1/TNL-1/IPNO-1/IPRT-1:staticRoutes:gateway
    Set Suite Variable  ${ipv4_src}     ${ipv4_src}
    Perform Recommissioning        type=param           param_path=SECADM-1:ethernetPortSecurityEnabled    operation=update     value=true
...     timeout=60
    PM Counters Start   analysis=verify_dropped_packet_filtering_packet_drop    counter_analysis_file=${counter_analysis_file_name}    pm_interval=5
    #Send_IPV4_packets_TCP_to_M-plane_on_the_port_22_from_port_1500_with_flags_APRSF
    Set Suite Variable  ${srcport}      1500
    Set Suite Variable  ${dstport}      22
    Set Suite Variable  ${proto}        TCP
    ${tcp_packet}     ${tcp_time}=      Send Packets to BTS     profile=mplane_rate_limit_drop_flagFSRPA
    #Send_IPV4_packets_TCP_to_M-plane_on_the_port_443_from_port_1500_with_flags_APRSF
    Set Suite Variable  ${srcport}      1500
    Set Suite Variable  ${dstport}      443
    Set Suite Variable  ${proto}        TCP
    ${tcp1_packet}     ${tcp1_time}=      Send Packets to BTS     profile=mplane_rate_limit_drop_flagFSRPA
    ${total_packet}=    Evaluate    ${tcp_packet} + ${tcp1_packet}
    ${total_time}=  Evaluate    ${tcp_time} + ${tcp1_time}
    Sleep  300
    &{rate_limit_counters_list}=     Verify Pm Counters    pm_interval=5
    ...     analysis=verify_dropped_packet_filtering_packet_drop
    ...     counter_analysis_file=${counter_analysis_file_name}
