*** Settings ***
Documentation     [Procedure] "CB008267-Verification of Proxy_ARP_Gratuitous_ARP_Messages_IPV4_Multicast_Handling_with_ICMP_Broadcast_Disabled"
...               [Date] "Date of creation 03-07-2023"
...               [Author] "Mansi"
...               [QC_Path] "QC_Path in Test Plan"
...               [QC_ID] "QC_ID in Test Lab for reporting"
...               [Feature_ID] "CB008267"
...               [Funtional_Hash_Tags] "ARP, GARP,ICMP"
...               [Validation_status] Validated and Passed
...               [Validated_TestLine] CLOUD_R4A_CUS
...               [Validation Date] 20-06-2023


Resource        ${CURDIR}/resources/CB008267_common_keywords.robot

Suite Setup     Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown  Run Keywords    Suite Teardown Postconditions
...     AND     Teardown Oamops

*** Test Cases ***
[1]CB008267-D_Verification of Proxy_ARP_Gratuitous_ARP_Messages_IPV4_Multicast_Handling_with_ICMP_Broadcast_Disabled
    Check Proxy ARP is disabled
    Check Gratuitous ARP messaging is disabled
    Get LMP Interface MAC
    Traffic Capture Start   capture_device=bts   alias=parp_garp
    Execute command on GNB          arping -I ethlmp0 ${lmp_ip} -c 10
    Sleep   10
    ${filename_A}=  Traffic Capture Stop    capture_device=bts   alias=parp_garp
    Set Suite Variable          ${filename_A}
    Analyse pcap for parp and garp

	Check ICMP broadcasting is disabled
    Check network product doesn't respond to the ICMP broadcast ping
    Check ICMP broadcasting is enabled and getting response for ICMP broadcast ping

	Check IP multicast handling is disabled
	Perform software upgrade
	Check Proxy ARP is disabled
    Check Gratuitous ARP messaging is disabled
    Get LMP Interface MAC
    Traffic Capture Start   capture_device=bts   alias=parp_garp
    Execute command on GNB          arping -I ethlmp0 ${lmp_ip} -c 10
    Sleep   10
    ${filename_A}=  Traffic Capture Stop    capture_device=bts   alias=parp_garp
    Set Suite Variable          ${filename_A}
    Analyse pcap for parp and garp
	Check ICMP broadcasting is disabled
    Check network product doesn't respond to the ICMP broadcast ping
    Check ICMP broadcasting is enabled and getting response for ICMP broadcast ping
    [Teardown]     Run Keyword And Ignore Error     Execute command on GNB       echo 1 > ICMP_echo_ignore
	Check IP multicast handling is disabled
