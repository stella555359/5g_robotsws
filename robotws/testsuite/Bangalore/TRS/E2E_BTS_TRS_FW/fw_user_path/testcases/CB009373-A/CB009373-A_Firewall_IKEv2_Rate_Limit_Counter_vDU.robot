*** Settings ***
Documentation
...     [Author]        "Sushma R"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Procedure] "The test case checks the support for IKE and M/Cplane rate limiting functionality on vDU"
...     [Date]      "30-05-2023"
...     [QC_Path]   "QC_Path in Test Plan"
...     [QC_ID]     "Verify rate limiting on vDU for IKE and M/Cplane"
...     [Funtion_Hash_Tags] "Rate Limiting"
...     [Feature_ID]            "CB009373-A"
...     [Requirement ID]    "TT_TTSEC.1023 TT_TTSEC.2356"
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
[1]CB009373-A_Firewall_Ikev2_and_Udp_Rate_Limit_Counter_VDU
    Comment     Scenario covering no drop when packet within ratelimit
    Comment     Add SCF file with IPsec MO added and IPSEC enabled on CPRT POD
    Setup Oamops    dut=cbts    alias=con22
    Perform Commissioning    dut=cbts    scf_file=${comm_file}    timeout=120    alias=con22
    Pm Counters Start    dut=cbts     analysis=verify_IKEv2_pcaket_no_drop
    ...     counter_analysis_file=${counter_analysis_file_name}     pm_interval=5    alias=con22
    Sending traffic   IKEv2_rate_limit_no_drop
    Sleep   300
    Verify PM Counters    dut=cbts    analysis=verify_IKEv2_pcaket_no_drop
    ...     counter_analysis_file=${counter_analysis_file_name}   pm_interval=5    alias=con22
    Teardown Oamops     dut=cbts     alias=con22
    Comment     Scenario to cover drop due to rate limit
    Setup Oamops    dut=cbts    alias=con22
    Pm Counters Start    dut=cbts     analysis=verify_IKEv2_pcaket_drop
    ...     counter_analysis_file=${counter_analysis_file_name}     pm_interval=5    alias=con22
    Sending traffic   IKEv2_rate_limit_drop
    Sleep   300
    Verify PM Counters    dut=cbts    analysis=verify_IKEv2_pcaket_drop
    ...     counter_analysis_file=${counter_analysis_file_name}  pm_interval=5    alias=con22
    Teardown Oamops     dut=cbts     alias=con22


[2]CB009373-A_Firewall_Mplane_Filtering_Counter_vDU
    Comment     Checking Filtering for Mplane traffic on OAM POD
    Setup Oamops    dut=cbts    alias=con22
    Pm Counters Start    dut=cbts     analysis=verify_ingress_filtering_mplane_drop
    ...     counter_analysis_file=${counter_analysis_file_name}     pm_interval=5    alias=con22
    Sending traffic   mplane_filtering_drop
    Sleep   300
    Verify PM Counters    dut=cbts    analysis=verify_ingress_filtering_mplane_drop
    ...     counter_analysis_file=${counter_analysis_file_name}   pm_interval=5    alias=con22
    Teardown Oamops     dut=cbts     alias=con22

[1]CB009373_A_Firewall_Mplane_and_CPlane_Rate_Limit_Counter_vDU
    Comment     Checking Filtering for Cplane traffic on CPRT POD for port 38472
    Setup Oamops    dut=cbts    alias=con22
    Perform Commissioning    dut=vcu    scf_file=${comm_file_cplane_rl}    timeout=300    alias=con22
    Pm Counters Start    dut=cbts     analysis=verify_ingress_filtering_cplane
    ...     counter_analysis_file=${counter_analysis_file_name}     pm_interval=5    alias=con22
    Sending traffic     cplane_filtering_drop
    Sleep   300
    Verify PM Counters    dut=cbts    analysis=verify_ingress_filtering_cplane
    ...     counter_analysis_file=${counter_analysis_file_name}   pm_interval=5    alias=con22
    Teardown Oamops     dut=cbts     alias=con22
