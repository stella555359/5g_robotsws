*** Settings ***
Documentation
...     [Documentation]
...     [Author]        "Sushma R"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Procedure] "The test case checks the support for ICMPv4 rate limiting functionality on vCU"
...     [Date]      "30-05-2023"
...     [QC_Path]   "QC_Path in Test Plan"
...     [QC_ID]     "Verify rate limiting on vCU for ICMPv4"
...     [Funtion_Hash_Tags] "Rate Limiting"
...     [Feature_ID]            "CB009373-A"
...     [Requirement ID]    "TT_TTSEC.1023"
...     [Validation_Status]    "Validated"
...     [Validated_TestLine]    "9373"
...     [Config]    "This testcase requires basic configuration with oam IP"
...     [scf_file]  "Actual_configuration_scf_MRBTS-5562_vCU5561_20230617-1911_IPSEC.xml"


Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/common_keywords_CB009373_A.robot


Suite Teardown  Run Keywords    Setup Oamops    dut=vcu_9373_b      alias=default   AND     Collect Snapshot
...     dut=vcu_9373_b  operation_timeout=300   alias=default   AND     Run Keyword And Ignore Error
...     Teardown Oamops     dut=vcu_9373_b     alias=default




*** Test Cases ***
[1]Checking counters in vCU while sending ICMP ECHO REQUEST packets
    Comment     Sending ICMP echo request packets from Cluster to oam pod and checking ingress
    Comment     icmp echo request rate limiting
    Setup Oamops    dut=vcu_9373_b    alias=con22
    Perform Commissioning    dut=vcu_9373_b    scf_file=${comm_file_cu1}    timeout=300    alias=con22
    Check vmAllocated   oam_pod     vcu_9373_b
    Pm Counters Start    dut=vcu_9373_b    analysis=verify_ICMP_pcaket_drop_CU
    ...     counter_analysis_file=${counter_analysis_file_name}       pm_interval=5      alias=con22
    Send ICMP traffic to CU     ${cu_oam_pod_ip}
    Sleep   90
    Verify PM Counters    dut=vcu_9373_b    analysis=verify_ICMP_pcaket_drop_CU
    ...     counter_analysis_file=${counter_analysis_file_name}    pm_interval=5   alias=con22
    Teardown Oamops     dut=vcu_9373_b     alias=con22
    Comment     Sending ICMP echo request packets from cluster to cpif pod and checking ingress icmp echo req RL
    Setup Oamops    dut=vcu_9373_b    alias=con22
    Pm Counters Start    dut=vcu_9373_b    analysis=verify_ICMP_pcaket_drop_cpif_CU
    ...     ounter_analysis_file=${counter_analysis_file_name}       pm_interval=5      alias=con22
    Send ICMP traffic to CU   ${cpif_pod_ip}
    Sleep   300
    Verify PM Counters    dut=vcu_9373_b    analysis=verify_ICMP_pcaket_drop_cpif_CU
    ...     counter_analysis_file=${counter_analysis_file_name}    pm_interval=5   alias=con22
    Teardown Oamops     dut=vcu_9373_b     alias=con22

    Comment     Sending ICMP other  messages
    Setup Oamops    dut=vcu_9373_b    alias=con25
    Sending ICMP traffic    echo-reply  vcu_9373_b     icmpv4_rate_limit_drop_test_cu
    ...     verify_ICMP_pcaket_drop_CU_other
    Sending ICMP traffic    dest-unreach    vcu_9373_b     icmpv4_rate_limit_drop_test_cu
    ...     verify_ICMP_pcaket_drop_CU_other
    Sending ICMP traffic    time-exceeded   vcu_9373_b     icmpv4_rate_limit_drop_test_cu
    ...     verify_ICMP_pcaket_drop_CU_other
    Run keyword and Ignore Error    Teardown Oamops     dut=vcu_9373_b     alias=con25

    Comment     Sending Invalid ICMP messages are dropped silently
    Setup Oamops    dut=vcu_9373_b    alias=con25
    Sending ICMP traffic   echo-reply  vcu_9373_b     icmpv4_rate_limit_drop_test_cu_invalid
    ...     verify_ICMP_pcaket_invalid_no_drop
    [Teardown]  Run Keyword And Ignore Error       Teardown Oamops     dut=vcu_9373_b     alias=con25
