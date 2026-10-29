*** Settings ***

Documentation
...     [Author]        "Sushma R"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Procedure] "The test case checks the support for TWAMPrate limiting functionality on vDU"
...     [Date]      "30-05-2023"
...     [QC_Path]   "QC_Path in Test Plan"
...     [QC_ID]     "Verify rate limiting on vDU for TWAMP"
...     [Funtion_Hash_Tags] "Rate Limiting"
...     [Feature_ID]            "CB009373-A"
...     [Requirement ID]    "TT_TTSEC.1023"
...     [Validation_Status]    "Validated"
...     [Validated_TestLine]    "9373"
...     [Config]    "This testcase requires basic configuration with oam IP and TWAMP moc"
...     [scf_file]  "Actual_configuration_scf_MRBTS-5562_5gvDU-10829_20230620-1735_TWAMP.xml"


Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/common_keywords_CB009373_A.robot

Suite Teardown  Run Keywords    Setup Oamops    dut=vdu_9373_b      alias=default   AND     Collect Snapshot
...     dut=vdu_9373_b  operation_timeout=300   alias=default   AND     Run Keyword And Ignore Error
...     Teardown Oamops     dut=vdu_9373_b     alias=default

*** Test Cases ***
[1]CB009373-A_Firewall_Twamp_Rate_Limit_Counter_VDU
    Setup Oamops    dut=vdu    alias=conn22
    Perform Commissioning    dut=vdu    scf_file=${comm_file_twamp}    timeout=120    alias=conn22
    Pm Counters Start    dut=vdu     analysis=verify_twamp_pcaket_no_drop
    ...     counter_analysis_file=${counter_analysis_file_name}     pm_interval=5    alias=conn22
    Sending traffic   TWAMP_rate_limit_drop
    Sleep   300
    ${rate_limit_counters_list}=    Verify PM Counters    dut=vdu    analysis=verify_twamp_pcaket_drop
    ...     counter_analysis_file=${counter_analysis_file_name}  pm_interval=5    alias=conn22
    Set Suite Variable      ${rate_limit_counters_list}     ${rate_limit_counters_list}
    Verify Rate Limit From Admin For One Counter    ${rate_limit_counters_list}     ${total_packets_sent}
    ...     ${total_time}   ${rate_limit_to_verify}
    Teardown Oamops     dut=vdu     alias=conn22
