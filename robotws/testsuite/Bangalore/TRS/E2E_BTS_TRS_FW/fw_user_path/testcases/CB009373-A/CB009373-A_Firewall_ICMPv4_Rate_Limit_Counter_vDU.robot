*** Settings ***
Documentation
...     [Author]        "Sushma R"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Procedure] "The test case checks the support for ICMPv4 rate limiting functionality on vDU"
...     [Date]      "30-05-2023"
...     [QC_Path]   "QC_Path in Test Plan"
...     [QC_ID]     "Verify rate limiting on vDU for ICMPv4"
...     [Funtion_Hash_Tags] "Rate Limiting"
...     [Feature_ID]            "CB009373-A"
...     [Requirement ID]    "TT_TTSEC.1023"
...     [Validation_Status]    "Validated"
...     [Validated_TestLine]    "9373"
...     [Config]    "This testcase requires basic configuration with oam IP"
...     [scf_file]  "Actual_configuration_scf_MRBTS-0_TL1101-DU_20230414-1121_IPSEC_enabled.xml"


Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/common_keywords_CB009373_A.robot

Suite Teardown  Run Keywords    Setup Oamops    dut=vdu_9373_b      alias=default   AND     Collect Snapshot
...     dut=vdu_9373_b  operation_timeout=300   alias=default   AND     Run Keyword And Ignore Error
...     Teardown Oamops     dut=vdu_9373_b     alias=default


*** Test Cases ***
[1]CB009373-A_Firewall_ICMP_Rate_Limit_Counter_VDU
    Comment     Checking counters in vDU while sending ICMP ECHO REQUEST packets
    Comment     Sending ICMP echo request packets from Cluster to oam pod and checking ingress icmp echo
    Comment     request rate limiting
    Setup Oamops    dut=vdu_9373_b    alias=con22
    Perform Commissioning    dut=vdu_9373_b    scf_file=${comm_file_du1}    timeout=300    alias=con22
    Teardown Oamops     dut=vdu_9373_b     alias=con22
    Setup Oamops    dut=vdu_9373_b    alias=con22
    Pm Counters Start    dut=vdu_9373_b    analysis=verify_ICMP_pcaket_drop
    ...     counter_analysis_file=${counter_analysis_file_name}       pm_interval=5      alias=con22
    Send ICMP traffic   ${oam_pod_ip}
    Sleep    90
    Verify PM Counters    dut=vdu_9373_b    analysis=verify_ICMP_pcaket_drop
    ...     counter_analysis_file=${counter_analysisl_file_name}    pm_interval=5   alias=con22
    Teardown Oamops     dut=vdu_9373_b     alias=con22
    Setup Oamops    dut=vdu_9373_b    alias=con22
    Pm Counters Start    dut=vdu_9373_b    analysis=verify_ICMP_pcaket_drop_cpif
    ...     counter_analysis_file=${counter_analysis_file_name}       pm_interval=5      alias=con22
    Send ICMP traffic   ${cpif_pod_ip}
    Sleep   300
    Verify PM Counters    dut=vdu_9373_b    analysis=verify_ICMP_pcaket_drop_cpif
    ...     counter_analysis_file=${counter_analysis_file_name}    pm_interval=5   alias=con22
    Teardown Oamops     dut=vdu_9373_b     alias=con22


    Comment     Sending ICMP other  messages
    Setup Oamops    dut=vdu_9373_b    alias=vdu
    Sending ICMP traffic    echo-reply  vdu_9373_b  icmpv4_rate_limit_drop_test
    ...     verify_ICMP_pcaket_drop
    Sending ICMP traffic    dest-unreach    vdu_9373_b    icmpv4_rate_limit_drop_test
    ...     verify_ICMP_pcaket_drop
    Sending ICMP traffic    time-exceeded   vdu_9373_b   icmpv4_rate_limit_drop_test
    ...     verify_ICMP_pcaket_drop
    Run Keyword and Ignore Error    Teardown Oamops     dut=vdu_9373_b     alias=vdu

    Comment     Sending Invalid ICMP messages are dropped silently
    Setup Oamops    dut=vdu_9373_b    alias=con25
    Sending ICMP traffic   echo-reply  vdu_9373_b     icmpv4_rate_limit_drop_test_du_invalid
    ...     verify_ICMP_pcaket_invalid_no_drop
    [Teardown]  Run Keyword And Ignore Error       Teardown Oamops     dut=vdu_9373_b     alias=con25
