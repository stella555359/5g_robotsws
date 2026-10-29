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
...     [Config_Comments]       "This script requires basic SCF loading and Change rule_type variable value in tescase_variable.json as per HW"

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/packet_generation_verification_common_keywords.robot


Suite Setup     Run Keywords        Suite Setup Preconditions        AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions       AND     Teardown Oamops

*** Variables ***
${time}     15min
${profile}      icmpv4_rate_limit_drop

*** Test Cases ***
[1]CB005750-5G-EBAJ-SyVe 5GC001577-KA_5GC000265_043_SyVe_Egress_rate_limiting_ICMP_Echo_Request
    BuiltIn.sleep  700
    Run Keyword If      '${rule_type}'=='nftlist'   SyVe_Egress_rate_limiting_ICMP_Echo_Request_NFTlist
    Run Keyword If      '${rule_type}'=='iptables'  SyVe_Egress_rate_limiting_ICMP_Echo_Request_IPtable

*** Keywords ***

SyVe_Egress_rate_limiting_ICMP_Echo_Request_NFTList
    Setup Remote Access     remote_device=bts
    ${cmd_output} =          Remote Command Execute     command=nft list chain ip filter EGRESS_ECHO_REQUEST
    Should Contain      ${cmd_output}       limit rate 25/second burst 8 packets
    [Teardown]      Teardown Remote Access

SyVe_Egress_rate_limiting_ICMP_Echo_Request_IPtable
    Setup Remote Access     remote_device=bts
    ${cmd_output}=     Remote Command Execute      command=iptables -nvL ICMP_EGRESS
    Should Contain      ${cmd_output}       'cmptype 8 limit:avg 25/sec burst 8'

Fetch Ingress Rules From Board
    Run Keyword If      '${rule_type}'=='nftlist'   Fetch Ingress Rules From NFTLIST And Verify
    Run Keyword If      '${rule_type}'=='iptables'  Fetch Ingress Rules From IPTABLES And Verify

