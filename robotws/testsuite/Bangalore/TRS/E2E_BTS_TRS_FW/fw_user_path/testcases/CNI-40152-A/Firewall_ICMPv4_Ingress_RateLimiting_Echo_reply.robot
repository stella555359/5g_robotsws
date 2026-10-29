** Settings ***
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
...     [Config_Comments]       "This script requires basic SCF loading and Change rule_type variable value in tescase_variable.json as per HW"

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/packet_generation_verification_common_keywords.robot

Suite Setup     Run Keywords        Suite Setup Preconditions        AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions       AND     Teardown Oamops

*** Variables ***
${time}             15min
${profile}          icmpv4_rate_limit_drop

*** Test Cases ***

[1]CB005750-5G-EBAJ-SyVe 5GC001577-KA_5GC000265_012_SyVe_Ingress_rate_limiting_ICMP_Echo_Replay_to_U_M_S_C_planes_LMP_IP
   SyVe_Ingress_rate_limiting_ICMP_Echo_Reply_to_M-plane_IP
   SyVe_Ingress_rate_limiting_ICMP_Echo_Reply_to_C-plane_IP
   SyVe_Ingress_rate_limiting_ICMP_Echo_Reply_to_U-plane_IP
   SyVe_Ingress_rate_limiting_ICMP_Echo_Reply_to_S-plane_IP

*** Keywords ***
SyVe_Ingress_rate_limiting_ICMP_Echo_Request_to_S-plane_IP
    Verify_Ingress_Rate_Limit_For_IPv4_ICMPv4_8_0_to_S-plane
SyVe_Ingress_rate_limiting_ICMP_Echo_Reply_to_S-plane_IP
    Verify_Ingress_Rate_Limit_For_IPv4_ICMPv4_0_0_to_S-plane
SyVe_Ingress_rate_limiting_ICMP_time_exceeded_to_S-plane_IP
    Verify_Ingress_Rate_Limit_For_IPv4_ICMPv4_11_0_to_S-plane
SyVe_Ingress_rate_limiting_ICMP_parameter_problem_to_S-plane_IP
    Verify_Ingress_Rate_Limit_For_IPv4_ICMPv4_12_0_to_S-plane
SyVe_Ingress_rate_limiting_ICMP_destination_unreachable_to_S-plane_IP
    Verify_Ingress_Rate_Limit_For_IPv4_ICMPv4_3_0_to_S-plane

SyVe_Ingress_rate_limiting_ICMP_Echo_Reply_to_M-plane_IP
    Verify_Ingress_Rate_Limit_For_IPv4_ICMPv4_0_0_to_M-plane
SyVe_Ingress_rate_limiting_ICMP_parameter_problem_to_M-plane_IP
    Verify_Ingress_Rate_Limit_For_IPv4_ICMPv4_12_0_to_M-plane
SyVe_Ingress_rate_limiting_ICMP_destination_unreachable_to_M-plane_IP
    Verify_Ingress_Rate_Limit_For_IPv4_ICMPv4_3_0_to_M-plane

SyVe_Ingress_rate_limiting_ICMP_destination_unreachable_to_LMP_IP
    Verify_Ingress_Rate_Limit_For_IPv4_ICMPv4_3_0_to_LMP
SyVe_Ingress_rate_limiting_ICMP_Echo_Reply_to_LMP_IP
    Verify_Ingress_Rate_Limit_For_IPv4_ICMPv4_0_0_to_LMP

SyVe_Ingress_rate_limiting_ICMP_parameter_problem_to_C-plane_IP
    Verify_Ingress_Rate_Limit_For_IPv4_ICMPv4_12_0_to_C-plane
SyVe_Ingress_rate_limiting_ICMP_destination_unreachable_to_C-plane_IP
    Verify_Ingress_Rate_Limit_For_IPv4_ICMPv4_3_0_to_C-plane
SyVe_Ingress_rate_limiting_ICMP_Echo_Reply_to_C-plane_IP
    Verify_Ingress_Rate_Limit_For_IPv4_ICMPv4_0_0_to_C-plane

SyVe_Ingress_rate_limiting_ICMP_Echo_Reply_to_U-plane_IP
    Verify_Ingress_Rate_Limit_For_IPv4_ICMPv4_0_0_to_U-plane
SyVe_Ingress_rate_limiting_ICMP_parameter_problem_to_U-plane_IP
    Verify_Ingress_Rate_Limit_For_IPv4_ICMPv4_12_0_to_U-plane
SyVe_Ingress_rate_limiting_ICMP_destination_unreachable_to_U-plane_IP
    Verify_Ingress_Rate_Limit_For_IPv4_ICMPv4_3_0_to_U-plane



Verify_Ingress_Rate_Limit_For_IPV4_ICMPV4_${type}_0_to_${plane}
    Perform Recommissioning        type=param           param_path=PMTNLINT-1:ipFilteringInterval     operation=update     value=${time}
...     timeout=300
    Traffic Setup       device=device_1
#    Fetch Ingress Rules From Board

    Get IPs To Ping For IPv4        ${plane}

    Set Suite Variable  ${type}
    Test Ipconnectivity       remote_address=${ipv4_src}       dscp=10       payload_size=16       source_address=${ipv4_dest}       timeout=30
...     alias=default

    PM Counters Start   analysis=verify_icmp_ingress_rate_limit_packet_drop    counter_analysis_file=${counter_analysis_file_name}
...     pm_interval=15

    ${total_p_sent}     ${total_time}=      Send Packets to BTS     ${profile}      ${type}
    Sleep  200
    &{rate_limit_counters_list}=     Verify Pm Counters    pm_interval=15
    ...     analysis=verify_icmp_ingress_rate_limit_packet_drop
    ...     counter_analysis_file=${counter_analysis_file_name}

     [Teardown]     Traffic Setup


Get IPs To Ping For IPv4
    [Arguments]     ${plane}
    ${ipv4_src} =    Get Parameter   param_path=MRBTS-3927/TNLSVC-1/TNL-1/IPNO-1/IPRT-1:staticRoutes:gateway
    ${mplane_ipv4_dest} =   Get Parameter   param_path=${mplane_ipv4_moc_path}
    ${uplane_ipv4_dest} =   Get Parameter   param_path=${uplane_ipv4_moc_path}
    ${splane_ipv4_dest} =   Get Parameter   param_path=${splane_ipv4_moc_path}
    ${cplane_ipv4_dest} =   Get Parameter   param_path=${cplane_ipv4_moc_path}
    Set Suite Variable  ${ipv4_src}
    Run keyword IF  '${plane}'=='M-plane'    Set Suite Variable    ${ipv4_dest}        ${mplane_ipv4_dest}
    Run Keyword IF  '${plane}'=='U-plane'    Set Suite Variable    ${ipv4_dest}        ${uplane_ipv4_dest}
    Run Keyword IF  '${plane}'=='C-plane'    Set Suite Variable    ${ipv4_dest}        ${cplane_ipv4_dest}
    Run Keyword If  '${plane}'=='S-plane'    Set Suite Variable    ${ipv4_dest}        ${splane_ipv4_dest}

