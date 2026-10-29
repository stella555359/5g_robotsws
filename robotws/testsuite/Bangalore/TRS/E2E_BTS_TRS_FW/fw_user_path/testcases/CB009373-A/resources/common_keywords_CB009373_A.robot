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

Variables       ta_e2e_bts_trs_fw
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/../../resources/common_Cloud_keywords.robot


*** Keywords ***
Send ICMP traffic
    [Arguments]     ${pod_ip}
    Setup Remote Access    remote_device=cbts.ocp     alias=conn26
    ${output}=  Execute Interactive Remote Command     command=sudo ping ${pod_ip} -c 40 -i 0.022
    ...     exit_prompt=$   alias=conn26
    Should Contain  ${output}   ${received_packet_count}
    Teardown Remote Access  alias=conn26

Send ICMP traffic to CU
    [Arguments]     ${pod_ip}
    Setup Remote Access    remote_device=vcu.ocp     alias=conn27
    ${output}=      Execute Interactive Remote Command     command=sudo ping ${pod_ip} -c 40 -i 0.022
    ...     exit_prompt=$   alias=conn27
    Should Contain  ${output}   ${received_packet_count}
    Teardown Remote Access  alias=conn27


Sending ICMP traffic
    [Arguments]     ${traffic_type}     ${type_dut}     ${profile}      ${analysis}
    Traffic Setup       device=device_1
    Pm Counters Start    dut=${type_dut}     analysis=${analysis}    counter_analysis_file=${counter_analysis_file_name}
    ...     pm_interval=5      alias=con25
    ${p_echo_resp}    ${t_echo_resp}=    Send Packets to BTS     profile=${profile}  type='${traffic_type}'
    Sleep   300
    Verify PM Counters    dut=${type_dut}  analysis=${analysis}    counter_analysis_file=${counter_analysis_file_name}
    ...     pm_interval=5      alias=conn25
    [Teardown]  Run Keyword And Ignore Error        Traffic Teardown

Sending traffic
    [Arguments]     ${profile}
    Traffic Setup       device=device_1
    ${packets}  ${time}=    Send Packets to BTS      profile=${profile}
    Run Keyword If  '${profile}' == 'TWAMP_rate_limit_drop_cu'  Set Suite Variable  ${total_packets_sent}   ${packets}
    Run Keyword If  '${profile}' == 'TWAMP_rate_limit_drop_cu'  Set Suite Variable  ${total_time}   ${time}
    Run Keyword And Ignore Error        Traffic Teardown
