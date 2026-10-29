*** Settings ***

Documentation
...     [Documentation]
...     [Author]        "Sushma R"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Procedure] "The test case checks the support for TWAMP rate limiting functionality on vCU"
...     [Date]      "30-05-2023"
...     [QC_Path]   "QC_Path in Test Plan"
...     [QC_ID]     "Verify rate limiting on vCU for TWAMP"
...     [Funtion_Hash_Tags] "Rate Limiting"
...     [Feature_ID]            "CB009373-A"
...     [Requirement ID]    "TT_TTSEC.1839"
...     [Validation_Status]    "Validated"
...     [Validated_TestLine]    "9373"
...     [Config]    "This testcase requires basic configuration with oam IP and TWAMP MOC"
...     [scf_file]  "Actual_configuration_scf_MRBTS-5562_vCU5562_20230620-1614_Netact.xml"


Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/common_keywords_CB009373_A.robot

Suite Teardown  Run Keywords    Setup Oamops    dut=vcu_9373_b      alias=default   AND     Collect Snapshot
...     dut=vcu_9373_b  operation_timeout=300   alias=default   AND     Run Keyword And Ignore Error
...     Teardown Oamops     dut=vcu_9373_b     alias=default


*** Test Cases ***
[1]CB009373-A_Firewall_Twamp_Rate_Limit_Counter_VCU
    Setup Oamops    dut=vcu    alias=conn22
    Perform Commissioning    dut=vcu    scf_file=${comm_file_twamp_cu}    timeout=300    alias=conn22
    Pm Counters Start    dut=vcu     analysis=verify_twamp_pcaket_drop_vcu
    ...     counter_analysis_file=${counter_analysis_file_name}     pm_interval=5    alias=conn22
    Sending traffic   TWAMP_rate_limit_drop_cu
    Sleep   300
    ${rate_limit_counters_list}=    Verify PM Counters    dut=vcu    analysis=verify_twamp_pcaket_drop_vcu
    ...     counter_analysis_file=${counter_analysis_file_name}  pm_interval=5    alias=conn22
    Set Suite Variable      ${rate_limit_counters_list}     ${rate_limit_counters_list}
    Verify Rate Limit From Admin For One Counter    ${rate_limit_counters_list}     ${total_packets_sent}
    ...     ${total_time}   ${rate_limit_to_verify}
    Teardown Oamops     dut=vcu     alias=conn22\
