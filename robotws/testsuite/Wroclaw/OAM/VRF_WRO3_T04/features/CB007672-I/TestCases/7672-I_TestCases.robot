*** Settings ***
Documentation       Test Cases for CB007672-5G-I-SR000870 - Flexible IP Addressing for PKI

Resource            ../Resources/7672-I_keywords.robot
Resource            ../../../common_resources/certificates/certificates.robot
Resource            ../../../common_resources/ip_traffic/ip_traffic.robot

*** Variables ***
${cmp_IPv4_address}                 10.42.54.13
${cmp_IPv6_address}                 2a00:8a00:6000:607c::1f04
${invalid_flexible_ipv4_address}    10.10.10.10
${invalid_flexible_ipv6_address}    2a00:8a00:6000:0000::1:ae0d
@{allowed_alarms}                   4681

# Capturing at NE_Terminated breaks IPv6.
# Until that's resolved, it must be done at Transport_Interface for all IPv6 tests.

*** Keywords ***
CB007672-5G-I-Deploying_Flexible_IPv4_addressing_for_PKI_feature_via_NetAct
    [Documentation]   The goal of this TC is to verify the possibility to deploy flexible IPv4 address for PKI.
    ...               When the flexible IPv4 address for PKI is deployed BTS will communicate with CMP/CRL via defined
    ...               flexible address (cmpCrlSrcIpv4AddressDN).
    ...               For This purpose IPv4 x2Cplane address is used.
    CRL Setup
    Configure CMP    bts_id=${BTS_ID}
    ...              ca_subject_name=C=PL, O=Common, CN=IPSEC
    ...              ca_server_host=${cmp_IPv4_address}
    Run Keyword And Ignore Error        Set Initial CMP Server Settings
    Reset Site And Check Alarms         ${allowed_alarms}
    Initialize Certificate
    Deploy flexible address for PKI     ipversion=4
    Start Tcpdump
    Trigger Action Towards CMP/CRL Server And Verify Result    cmp_action_expected_result=Succeed
    ${pcap_file}=    Stop Tcpdump And Download Pcap
    Check if gNB communicates with CMP/CRL server via defined dedicated CMP IP address
    ...              pcap_file=${pcap_file}
    ...              ipversion=4
    ...              ip_src=${X2C}
    ...              ip_dst=${cmp_IPv4_address}
    [Teardown]    Run Keywords    Undeploy flexible address for PKI    ipversion=4    AND
    ...                           Run Keyword And Ignore Error   Stop Tcpdump And Download Pcap

CB007672-5G-I-Deploying_Flexible_IPv6_addressing_for_PKI_feature_via_NetAct
    [Documentation]   The goal of this TC is to verify the possibility to deploy flexible IPv6 address for PKI.
    ...               When the flexible IPv6 address for PKI is deployed BTS will communicate with CMP/CRL via defined
    ...               flexible address (cmpCrlSrcIpv4AddressDN).
    ...               For This purpose IPv6 x2Cplane address is used.
    CRL Setup
    Configure CMP    bts_id=${BTS_ID}
    ...              ca_subject_name=C=PL, O=Common, CN=IPSEC
    ...              ca_server_host=${cmp_IPv6_address}
    ...              ca_server_port=8085
    Run Keyword And Ignore Error     Set Initial CMP Server Settings
    Initialize Certificate
    Deploy flexible address for PKI    ipversion=6
    Start Tcpdump    measurement_point=Transport_Interface
    Trigger Action Towards CMP/CRL Server And Verify Result    cmp_action_expected_result=Succeed
    ${pcap_file}=    Stop Tcpdump And Download Pcap    tcpdump_filename=test_IPv6.pcap
    Check if gNB communicates with CMP/CRL server via defined dedicated CMP IP address
    ...              pcap_file=${pcap_file}
    ...              ipversion=6
    ...              ip_src=${X2C_V6}
    ...              ip_dst=${cmp_IPv6_address}
    [Teardown]    Run Keywords    Undeploy flexible address for PKI    ipversion=6    AND
    ...                           Run Keyword And Ignore Error   Stop Tcpdump And Download Pcap

CB007672-5G-I-Undeploying_Flexible_IPv4_addressing_for_PKI_feature_via_NetAct
    [Documentation]   The goal of this TC is to verify the possibility to undeploy flexible IPv4 address for PKI.
    ...               When the flexible IPv4 address for PKI is undeployed there BTS will communicate with CMP/CRL
    ...               via IPv4 mPlane address.
    CRL Setup
    Configure CMP    bts_id=${BTS_ID}
    ...              ca_subject_name=C=PL, O=Common, CN=IPSEC
    ...              ca_server_host=${cmp_IPv4_address}
    Run Keyword And Ignore Error     Set Initial CMP Server Settings
    Initialize Certificate
    Deploy flexible address for PKI    ipversion=4
    Undeploy flexible address for PKI    ipversion=4
    Start Tcpdump
    Trigger Action Towards CMP/CRL Server And Verify Result    cmp_action_expected_result=Succeed
    ${pcap_file}=    Stop Tcpdump And Download Pcap
    Check if gNB communicates with CMP/CRL server via mplane address
    ...              pcap_file=${pcap_file}
    ...              ipversion=4
    ...              ip_src=${MPLANE_IPV4}
    ...              ip_dst=${cmp_IPv4_address}
    [Teardown]    Run Keyword And Ignore Error   Stop Tcpdump And Download Pcap

CB007672-5G-I-Undeploying_Flexible_IPv6_addressing_for_PKI_feature_via_NetAct
    [Documentation]   The goal of this TC is to verify the possibility to undeploy flexible IPv6 address for PKI.
    ...               When the flexible IPv6 address for PKI is undeployed there BTS will communicate with CMP/CRL
    ...               via IPv6 mPlane address.
    CRL Setup
    Configure CMP    bts_id=${BTS_ID}
    ...              ca_subject_name=C=PL, O=Common, CN=IPSEC
    ...              ca_server_host=${cmp_IPv6_address}
    ...              ca_server_port=8085
    Run Keyword And Ignore Error     Set Initial CMP Server Settings
    Initialize Certificate
    Deploy flexible address for PKI    ipversion=6
    Undeploy flexible address for PKI    ipversion=6
    Start Tcpdump    measurement_point=Transport_Interface
    Trigger Action Towards CMP/CRL Server And Verify Result    cmp_action_expected_result=Succeed
    ${pcap_file}=    Stop Tcpdump And Download Pcap    tcpdump_filename=test_IPv6.pcap
    Check if gNB communicates with CMP/CRL server via mplane address
    ...              pcap_file=${pcap_file}
    ...              ipversion=6
    ...              ip_src=${MPLANE_IPV6}
    ...              ip_dst=${cmp_IPv6_address}
    [Teardown]    Run Keyword And Ignore Error   Stop Tcpdump And Download Pcap

CB007672-5G-I-Invalid_Flexible_IPv4_addressing_for_PKI_feature_via_NetAct
    [Documentation]   The goal of this TC is to verify BTS behavior in case of invalid felxible IPv4 address for PKI.
    ...               When the flexible IPv4 address for PKI is invalid BTS shoudn't communicate with CMP/CRL (even via
    ...               mPlane address).
    CRL Setup
    Configure CMP    bts_id=${BTS_ID}
    ...              ca_subject_name=C=PL, O=Common, CN=IPSEC
    ...              ca_server_host=${cmp_IPv4_address}
    Run Keyword And Ignore Error     Set Initial CMP Server Settings
    Initialize Certificate
    Deploy invalid flexible address for PKI    ipversion=4
    Start Tcpdump
    Trigger Action Towards CMP/CRL Server And Verify Result    cmp_action_expected_result=Fail
    ${pcap_file}=    Stop Tcpdump And Download Pcap
    Check if gNB not communicates with CMP/CRL server via defined CMP IP address
    ...    pcap_file=${pcap_file}
    ...    ipversion=4
    ...    ip_src=${invalid_flexible_ipv4_address}
    ...    ip_dst=${cmp_IPv4_address}

    # Robustness
    log to console    start robustness check
    Deploy flexible address for PKI    ipversion=4
    Start Tcpdump
    Trigger Action Towards CMP/CRL Server And Verify Result    cmp_action_expected_result=Succeed
    ${pcap_file}=    Stop Tcpdump And Download Pcap    tcpdump_filename=robustness.pcap
    Check if gNB communicates with CMP/CRL server via defined dedicated CMP IP address
    ...    pcap_file=${pcap_file}
    ...    ipversion=4
    ...    ip_src=${X2C}
    ...    ip_dst=${cmp_IPv4_address}
    #

    [Teardown]    Run Keywords  Undeploy flexible address for PKI    ipversion=4    AND
    ...                         Perform recommissioing for IPADDRESS object with invalid IP address   operation=delete
    ...                                                                                               ipversion=4
    ...                         AND    Run Keyword And Ignore Error   Stop Tcpdump And Download Pcap

CB007672-5G-I-Invalid_Flexible_IPv6_addressing_for_PKI_feature_via_NetAct
    [Documentation]   The goal of this TC is to verify BTS behavior in case of invalid felxible IPv6 address for PKI.
    ...               When the flexible IPv6 address for PKI is invalid BTS shoudn't communicate with CMP/CRL (even via
    ...               mPlane address).
    CRL Setup
    Configure CMP    bts_id=${BTS_ID}
    ...              ca_subject_name=C=PL, O=Common, CN=IPSEC
    ...              ca_server_host=${cmp_IPv6_address}
    ...              ca_server_port=8085
    Run Keyword And Ignore Error     Set Initial CMP Server Settings
    Initialize Certificate
    Deploy invalid flexible address for PKI    ipversion=6
    Start Tcpdump    measurement_point=Transport_Interface
    Trigger Action Towards CMP/CRL Server And Verify Result    cmp_action_expected_result=Fail
    ${pcap_file}=    Stop Tcpdump And Download Pcap    tcpdump_filename=test_IPv6.pcap
    Check if gNB not communicates with CMP/CRL server via defined CMP IP address
    ...    pcap_file=${pcap_file}
    ...    ipversion=6
    ...    ip_src=${invalid_flexible_ipv6_address}
    ...    ip_dst=${cmp_IPv6_address}

    # Robustness
    log to console    start robustness check
    Deploy flexible address for PKI    ipversion=6
    Start Tcpdump
    Trigger Action Towards CMP/CRL Server And Verify Result    cmp_action_expected_result=Succeed
    ${pcap_file}=    Stop Tcpdump And Download Pcap    tcpdump_filename=robustness_IPv6.pcap
    Check if gNB communicates with CMP/CRL server via defined dedicated CMP IP address
    ...    pcap_file=${pcap_file}
    ...    ipversion=6
    ...    ip_src=${X2C_V6}
    ...    ip_dst=${cmp_IPv6_address}
    #

    [Teardown]    Run Keywords  Undeploy flexible address for PKI    ipversion=6    AND
    ...                         Perform recommissioing for IPADDRESS object with invalid IP address   operation=delete
    ...                                                                                               ipversion=6
    ...                         AND    Run Keyword And Ignore Error   Stop Tcpdump And Download Pcap

CB007672-5G-I-Flexible_IP_addressing_for_PKI_feature_on_Dual_Stack
    [Documentation]   The goal of this TC is to verify the possibility to deploy flexible IPv4 address for PKI and
    ...               flexible IPv6 address for PKI. When the flexible IPv4 address for PKI is deployed with invalid
    ...               adress and flexible IPv6 address for PKI is deployed with valid address, BTS will communicate
    ...               with CMP/CRL via defined flexible IPv6 address.
    ...               For This purpose IPv6 x2Cplane address is used.
    CRL Setup
    Configure CMP               bts_id=${BTS_ID}
    ...                         ca_subject_name=C=PL, O=Common, CN=IPSEC
    ...                         ca_server_host=${cmp_IPv4_address}
    Configure Secondary CMP     bts_id=${BTS_ID}
    ...                         subject_name=C=PL, O=Common, CN=IPSEC
    ...                         server_host=${cmp_IPv6_address}
    ...                         server_port=8085
    Run Keyword And Ignore Error     Set Initial CMP Server Settings
    Initialize Certificate
    Deploy invalid flexible address for PKI    ipversion=4
    Deploy flexible address for PKI            ipversion=6
    Start Tcpdump    measurement_point=Transport_Interface
    Trigger Action Towards CMP/CRL Server And Verify Result    cmp_action_expected_result=Succeed
    ${pcap_file}=    Stop Tcpdump And Download Pcap    tcpdump_filename=test_IPv6.pcap
    Check if gNB communicates with CMP/CRL server via defined dedicated CMP IP address
    ...              pcap_file=${pcap_file}
    ...              ipversion=6
    ...              ip_src=${X2C_V6}
    ...              ip_dst=${cmp_IPv6_address}
    [Teardown]    Run Keywords    Undeploy flexible address for PKI    ipversion=4    AND
    ...                           Undeploy flexible address for PKI    ipversion=6    AND
    ...                           Delete Secondary CMP   AND
    ...                           Perform recommissioing for IPADDRESS object with invalid IP address   operation=delete
    ...                                                                                                 ipversion=4
    ...                           AND    Run Keyword And Ignore Error   Stop Tcpdump And Download Pcap

CB007672-5G-I-Verifying_DSCP_setting_for_CRL_IPv4_traffic
    [Documentation]    The purpose of test is to check whether 5gNB correctly marks IP traffic towards CMP/CRL from
    ...                flexible source IP addresses with the DSCP value as configured for M-plane in parameter.
    ...                trafficTypeMap. For mPlaneDscp set to 32 trafficTypeMap should be 0x80.
    CRL Setup
    Configure CMP    bts_id=${BTS_ID}
    ...              ca_subject_name=C=PL, O=Common, CN=IPSEC
    ...              ca_server_host=${cmp_IPv4_address}
    Run Keyword And Ignore Error     Set Initial CMP Server Settings
    Initialize Certificate
    Change mPlaneDscp Value    mPlaneDscp=32
    Start Tcpdump
    Trigger Action Towards CMP/CRL Server And Verify Result    cmp_action_expected_result=Succeed
    ${pcap_file}=    Stop Tcpdump And Download Pcap    tcpdump_filename=mplane_dscp_IPv4.pcap
    Check If TOS Has Expected Expected Value
    ...              pcap_file=${pcap_file}
    ...              ipversion=4
    ...              ip_src=${MPLANE_IPV4}
    ...              ip_dst=${cmp_IPv4_address}
    ...              tos=0x80
    Deploy flexible address for PKI    ipversion=4
    Start Tcpdump
    Trigger Action Towards CMP/CRL Server And Verify Result    cmp_action_expected_result=Succeed
    ${pcap_file}=    Stop Tcpdump And Download Pcap    tcpdump_filename=flexible_address_dscp_IPv4.pcap
    Check If TOS Has Expected Expected Value
    ...              pcap_file=${pcap_file}
    ...              ipversion=4
    ...              ip_src=${X2C}
    ...              ip_dst=${cmp_IPv4_address}
    ...              tos=0x80
    [Teardown]    Run Keywords    Undeploy flexible address for PKI    ipversion=4    AND
    ...                           Run Keyword And Ignore Error   Stop Tcpdump And Download Pcap

CB007672-5G-I-Verifying_DSCP_setting_for_CRL_IPv6_traffic
    [Documentation]    The purpose of test is to check whether 5gNB correctly marks IP traffic towards CMP/CRL from
    ...                flexible source IP addresses with the DSCP value as configured for M-plane in parameter.
    ...                trafficTypeMap. For mPlaneDscp set to 32 trafficTypeMap should be 0x80.
    CRL Setup
    Configure CMP    bts_id=${BTS_ID}
    ...              ca_subject_name=C=PL, O=Common, CN=IPSEC
    ...              ca_server_host=${cmp_IPv6_address}
    ...              ca_server_port=8085
    Run Keyword And Ignore Error     Set Initial CMP Server Settings
    Initialize Certificate
    Change mPlaneDscp Value    mPlaneDscp=32
    Start Tcpdump    measurement_point=Transport_Interface
    Trigger Action Towards CMP/CRL Server And Verify Result    cmp_action_expected_result=Succeed
    ${pcap_file}=    Stop Tcpdump And Download Pcap    tcpdump_filename=mplane_dscp_IPv6.pcap
    Check If TOS Has Expected Expected Value
    ...              pcap_file=${pcap_file}
    ...              ipversion=6
    ...              ip_src=${MPLANE_V6MPLANE_V6}
    ...              ip_dst=${cmp_IPv6_address}
    ...              tos=0x80
    Deploy flexible address for PKI    ipversion=6
    Start Tcpdump    measurement_point=Transport_Interface
    Trigger Action Towards CMP/CRL Server And Verify Result    cmp_action_expected_result=Succeed
    ${pcap_file}=    Stop Tcpdump And Download Pcap    tcpdump_filename=flexible_address_dscp_IPv6.pcap
    Check If TOS Has Expected Expected Value
    ...              pcap_file=${pcap_file}
    ...              ipversion=6
    ...              ip_src=${X2C_V6}
    ...              ip_dst=${cmp_IPv6_address}
    ...              tos=0x80
    [Teardown]    Run Keywords    Undeploy flexible address for PKI    ipversion=6   AND
    ...                           Run Keyword And Ignore Error   Stop Tcpdump And Download Pcap
