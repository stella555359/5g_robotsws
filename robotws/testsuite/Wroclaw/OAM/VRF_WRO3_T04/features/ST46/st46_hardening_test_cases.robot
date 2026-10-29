*** Settings ***
Documentation
...     description:    Hardening test cases.

Resource    resources/robot/st46_rfrl_hardening_common_keywords.robot
Resource    resources/robot/st46_rfrl_certificate_common_keywords.robot
Resource    resources/robot/st46_rfrl_scapy_operations.robot
Library     resources/python/st46_rfrl_hardening.py
Library     taf.selenium.sbts  WITH NAME  sbts
Library     Collections

*** Keywords ***
Incorrect Password Update
	Check Incorrect Password Policy - Too Long
	Check Incorrect Password Policy - Too Short
	Check Incorrect Password Policy - Only One Digit
	Check Incorrect Password Policy - No Digit
	Check Incorrect Password Policy - No Upper Case Letter
	Check Incorrect Password Policy - No Lower Case Letter
	Check Incorrect Password Policy - Disallowed Character
	Check Incorrect Password Policy - Two Same Characters Consecutively
	Check Incorrect Password Policy - Contains Username In Straight Form
	Check Incorrect Password Policy - Contains Username In Reversed Form
	Check Incorrect Password Policy - No Special Character

Correct Password Update
    Check Correct Password Policy

Incorrect Username Update
    Check Incorrect Username Policy - Too Long
    Check Incorrect Username Policy - Too Short
    Check Incorrect Username Policy - With Disallowed Character

Correct Username Update
    Check Correct Username Policy

Check Files Permissions
    Check /etc/ Files Permissions and Root Ownership
    Check users.json File Permissions
    Check auditlogserver.db File Permissions
    Check SMOD Files Permissions
    Check BBMOD Files Permissions

Check Certificates Content
	Check Unencrypted Private Keys
	Check Firewall Nftables Ipv6 Ingress Rules For ICMP

Check Event Visibility In RUEM Logs
	Check If SSH User Is Automatically Logged Out After Reach Set Period Of Inactivity
	Check SSH User Event Visibility When Not Automatically Logged Out When Subprocess Is Running In SSH Session
	Check SSH User Events Visibility In SLNBI

Check If Alarm Related To Security Event Is Present
    Generate Binary File From HEX String    hex_string_file=${HEX_STRING_ADDITIONAL}
    ...                                     binary_file_name=${BINARY_FILE_RSA}
    Install Certificate On BTS              cert_file=${BINARY_FILE_RSA}
    ...                                     cert_type=BtsTrustChain
    ...                                     cert_format=P12
    ...                                     p12password=${NETOOPER_PASSWORD}
    ...                                     key_pool_type=RSA
    Change Parameter On BTS                 dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    ...                                     param_name=neCertificateUpdateTime
    ...                                     param_value=3660
    Wait Until Keyword Succeeds             10 min    30 sec    Alarm Should be Active In BTS    fault_id=61618
    Change Parameter On BTS                 dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                     param_name=ethernetPortSecurityEnabled
    ...                                     param_value=false
    Wait Until Keyword Succeeds             10 min    30 sec    Alarm Should be Active In BTS    fault_id=4654
    [Teardown]                              Run Keywords    Change Parameter On BTS
    ...                                                     dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                                     param_name=ethernetPortSecurityEnabled
    ...                                                     param_value=true
    ...                                     AND             Clear Certificates

WebEM Roles Privileges
    ${local_sw_path}=          Download Current BTS Software Version From Remote Repository
    Change Parameter On BTS    dist_name=MRBTS-${BTS_ID}/TNLSVC-1/PMTNLINT-1
    ...                        param_name=ipFilteringInterval
    ...                        param_value=5min
    Change Parameter On BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    ...                        param_name=reportingIntervalPm
    ...                        param_value=5min
    Change Parameter On BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1
    ...                        param_name=btsEMRestrictedAccessLogoutTimer
    ...                        param_value=100
    Log                        Waiting 5m for counters collection    console=${TRUE}
    builtin.sleep              5m                                    reason=Waiting for counters collection
    Check Account Operation Permisions For Nemuadmin                 local_sw_path=${local_sw_path}
    Check Account Operation Permisions For BTSApplication            local_sw_path=${local_sw_path}
    Check Account Operation Permisions For BTSSecurity               local_sw_path=${local_sw_path}
    Check Account Operation Permisions For BTSRead                   local_sw_path=${local_sw_path}
    [Teardown]    Run Keywords    Run    rm -rf /home/ute/Downloads/*
    ...           AND    Reset Local User Credentials By Removing users.json

Send Incorrect Traffic And Check If Is Blocked
    ${vm_ipv6}=                       Get VM IPv6 Address
    ${vm_password}=                   Get VM Password
    start_tshark_on_vm                pcap_file=vm_tcp_dump_1.pcap    vm_password=${vm_password}
    Start TCPDump
    Send Incorrect Packet Set Ipv6    ${MPLANE_IPV6}
    builtin.sleep                             30s    reason=Wait for capturing tcpdump logs
    ${tcpdump_path}=                  Stop TCPDump And Download PCAP    tcpdump_filename=wrong_packages.pcap
    Check Incorrect Packets           tcpdump_path=${tcpdump_path}
    ...                               base_filter=icmpv6 && ipv6.src==${vm_ipv6} && ipv6.dst==${MPLANE_IPV6}
    PCAP Should Be Empty
    ...    tshark_filter=icmpv6 && ipv6.src==${MPLANE_IPV6} && ipv6.dst==${vm_ipv6} && !icmpv6.nd.na.flag.o == 1
    ...    pcap_file=vm_tcp_dump_1.pcap
    stop_tshark_on_vm                 ${vm_password}
    start_tshark_on_vm                pcap_file=vm_tcp_dump_2.pcap    vm_password=${vm_password}
    Start TCPDump
    Send ICMPv6ND_NS                  ${MPLANE_IPV6}
    builtin.sleep                             30s    reason=Wait for capturing tcpdump logs
    ${tcpdump_path}=                  Stop TCPDump And Download PCAP    tcpdump_filename=nd_ns.pcap
    PCAP Should Contain Message
    ...    tshark_filter=icmpv6 && ipv6.src==${vm_ipv6} && ipv6.dst==${MPLANE_IPV6} && icmpv6.type == 135
    ...    pcap_file=${tcpdump_path}
    ${output}=                        PCAP Should Contain Message
    ...                               tshark_filter=icmpv6 && ipv6.src==${MPLANE_IPV6} && ipv6.dst==${vm_ipv6}
    ...                               pcap_file=vm_tcp_dump_2.pcap
    Should Contain                    ${output}       Neighbor Advertisement ${MPLANE_IPV6} (rtr, sol)
    [Teardown]                        Run Keywords    TCPDump Teardown
    ...                               AND             stop_tshark_on_vm    ${vm_password}

Send Correct Traffic And Check If Is Accepted
    Change Parameter On BTS           dist_name=MRBTS-${BTS_ID}/TNLSVC-1/PMTNLINT-1
    ...                               param_name=ipFilteringInterval
    ...                               param_value=5min
    Change Parameter On BTS           dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    ...                               param_name=reportingIntervalPm
    ...                               param_value=5min
    ${vm_ipv4}=                       Get VM IPv4 Address
    Reset Site And Reconnect
    Start TCPDump
    Send Packets For M51328C15 Counter To BTS    ${MPLANE_IPV4}
    Log                               Waiting 10 minutes for collect counters    console=${TRUE}
    builtin.sleep                             10m    reason=Wait for capturing tcpdump logs
    ${tcpdump_path}=                  Stop TCPDump And Download PCAP    tcpdump_filename=counter_packages.pcap
    ${output}=                        PCAP Should Contain Message
    ...                               tshark_filter=icmp && ip.src==${vm_ipv4} && ip.dst==${MPLANE_IPV4}
    ...                               pcap_file=${tcpdump_path}
    PCAP Should Contain Message       tshark_filter=icmp && ip.src==${MPLANE_IPV4} && ip.dst==${vm_ipv4}
    ...                               pcap_file=${tcpdump_path}
    Check If Counters Are Collected On BTS    M51328C15
    [Teardown]                        TCPDump Teardown
