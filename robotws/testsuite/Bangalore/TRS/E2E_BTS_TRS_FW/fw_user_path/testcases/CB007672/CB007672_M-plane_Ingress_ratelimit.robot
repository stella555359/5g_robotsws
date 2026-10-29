*** Settings ***
Documentation
...     [Procedure]             "The test case is planned to validate firewall rate limit for mplane packet"
...     [Date]                  "02-09-2021"
...     [Author]                "Vishal G"
...     [Maintenance]           "TRS ET Bangalore Team"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"
...     [Funtion_Hash_Tags]     "FIREWALL, COUNTERS, NETACT"
...     [Domain_Hash_Tags]      "counters"
...     [Feature_ID]            "RP000366,5G000265,CNI40152-A,CB007672,SR002103"
...     [Validation_status]     "Validated and Passed"
...     [Validated_TestLine]    "SBTS-3907"
...     [Procedure]             "The test case is planned to validate firewall rate limit for mplane packet"
...     [Config_Comments]       "This script requires basic SCF loading"
...     [RunTime Parameters]    "bts_id used is 3907 and we have pass the rule type depending on the HW. for ASOE
...                              it is nftlist"

Variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops

*** Test Cases ***
[1]CB007672_5G_Porting of SR002103_Verify_Mplane_RateLimiting_Counters
    [Documentation]     This test case validates firewall Ingress rate limit for Mplane traffic
    Perform Commissioning       scf_file=${Full_Configuration}   verify_bts_status=False     timeout=400     alias=default
	Sleep    900

    Setup Ems       config_device=netact3       alias=lab1042
    Cm Upload       config_device=netact3       alias=lab1042

    Fetch Ingress Rules From Board

    Read IP Parameter

    Traffic Setup        device=device_1

    @{rl_rules}=  Split String  ${rate_limit_rules}  ,
    Traffic Per Rule    @{rl_rules}

    [Teardown]  Run Keywords    Run Keyword And Ignore Error        Traffic Teardown
    ...     AND     Teardown Ems        config_device=netact3       alias=lab1042

*** Keywords ***
Read IP Parameter
     ${mplane} =     Get Parameter       param_path=${mplane_ip_moc_path}
     Set Suite Variable      ${mplane}       ${mplane}
     ${mplane_v6} =     Get Parameter       param_path=${mplane_v6_ip_moc_path}
     Set Suite Variable      ${mplane_v6}       ${mplane_v6}

Traffic Per Rule
    [Arguments]     @{rl_rules}
    FOR    ${prof}    IN    @{rl_rules}
           ${analysis} =   Set Variable If    '${prof}'=='mplane_rate_limit_no_drop'     verify_ingress_rate_limit_packet_no_drop
           ...    '${prof}'=='mplane_rate_limit_drop'     verify_ingress_rate_limit_packet_drop
           ...    '${prof}'=='mplane_rate_limit_no_drop_ipv6'     verify_ingress_rate_limit_v6_packet_no_drop
           ...    '${prof}'=='mplane_rate_limit_drop_ipv6'     verify_ingress_rate_limit_v6_packet_drop

           Start Netact Pm Counters      config_device=netact3     analysis=${analysis}
           ...     counter_analysis_file=${counter_analysis_file_name}     alias=lab1042
           Sleep   90

           @{protocols}=  Split String  ${mplane_protocols}  ,
           ${total_packets}  ${total_time}=     Traffic Per Protocol     ${prof}     @{protocols}

           &{rate_limit_counters_list}=     Verify Netact Pm Counters     config_device=netact3     analysis=${analysis}
           ...     counter_analysis_file=${counter_analysis_file_name}    alias=lab1042

           Verify Rate Limit Per Counter       ${rate_limit_counters_list}     ${total_packets}      ${total_time}
    END

    [Teardown]      Run Keyword And Ignore Error        Traffic Teardown

Verify Rate Limit Per Counter
    [Arguments]     ${rate_limit_counters_list}     ${totl_p_sent}      ${totl_time}

    &{rl_rules}=    Create Dictionary       ${C0}        ${mplane_rate_limit}          ${C11}       ${mplane_rate_limit}
    ${counter_list} =   Get Dictionary Values     ${rate_limit_counters_list}
    @{counters_to_verify}=     Create List      ${C0}        ${C11}
    FOR    ${counter}      IN     @{counters_to_verify}
           Verify Counter List Against Counter Number    ${counter_list}     ${counter}      ${totl_p_sent}     ${totl_time}
           ...      ${rl_rules['${counter}']}
    END

Verify Counter List Against Counter Number
    [Arguments]     ${counter_output_list}      ${counter}      ${packets_sent}     ${total_time}       ${rate_limit_to_verify}
    FOR   ${counter_content}      IN      ${counter_output_list}[0]
          ${content}=   Get From Dictionary         ${counter_content}        ${counter}
          Run Keyword If    ${content}==''      Exit For Loop
          ${rate_limit_counters_increased}=     Get From Dictionary     ${content}      final_counter_value

          ${counters_increased} =       Evaluate        ${packets_sent} - ${rate_limit_counters_increased}
          ${rate_limiting_speed} =      Evaluate     ${counters_increased} / ${total_time}
          ${packets_tolerance}=     Evaluate    ${rate_limit_to_verify} * 0.1
          ${packets_min}=   Evaluate    ${rate_limit_to_verify} - ${packets_tolerance}
          ${packets_max}=   Evaluate      ${rate_limit_to_verify} + ${packets_tolerance}

          Should be True    ${packets_min} < ${rate_limiting_speed} < ${packets_max}
          ...       msg=Rate Limiting not within 10% of expected ${rate_limit_to_verify}
    END

Traffic Per Protocol
    [Arguments]     ${prof}         @{protocols}
    Set Suite Variable      ${total_packets}    0
    Set Suite Variable      ${total_time}   0
    FOR    ${proto}    IN    @{protocols}
           Set Suite Variable        ${proto}        ${proto}
           ${packets}  ${time}=    Send Packets to BTS      profile=${prof}
           ${total_packets}=    Evaluate    ${total_packets} + ${packets}
           ${total_time}=   Evaluate    ${total_time} + ${time}
    END
    Return From Keyword     ${total_packets}  ${total_time}

Fetch Ingress Rules From Board
    [Documentation]     This keyword checks for the user defined runtime argument ${rule_type} and calls different
    ...     keywords accordingly.
#   ${rule_type} is pybot command line argument.
    Run Keyword If      '${rule_type}'=='nftlist'   Fetch Ingress Rules From NFTLIST And Verify
    Run Keyword If      '${rule_type}'=='iptables'  Fetch Ingress Rules From IPTABLES And Verify

Fetch Ingress Rules From NFTLIST And Verify
    Setup Remote Access     remote_device=bts
    ${output}=      Remote Command Execute
    ...     command=nft list chain inet filter INGRESS_RATELIMIT_CHAIN | grep INGRESS_RATELIMIT_CHAIN
    Log     ${output}
    [Teardown]      Teardown Remote Access

Fetch Ingress Rules From IPTABLES And Verify
    Setup Remote Access     remote_device=bts
    ${output}=      Remote Command Execute
    ...     command=iptables -nvL
    Log     ${output}
    [Teardown]      Teardown Remote Access
