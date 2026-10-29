*** Settings ***
Documentation    Suite for testing common_resources for cloud

Library    taf.transport.ssh       WITH NAME    ssh
Library    taf.gnb.oam.coam.vdu    WITH NAME    vdu_admin
Library    OperatingSystem
Library    DateTime
Library    ./resources.py

Resource    taf/rfrl/cbts/robot/webem_operations.robot

*** Variables ***

${IP_TEST_PC}=     10.42.63.239
${LOGIN_TEST_PC}=  trs
${PASS_TEST_PC}=   YT_xk39b

${CPLANE_NFT_CHAIN}=           nft list chain ip filter CPLANE5G_FRONTHAUL_OVERALL_RATELIMIT_CHAIN
${INPUT_NFT_CHAIN}=            nft list chain ip filter INPUT
${TWAMP_NFT_CHAIN}=            nft list chain ip filter TWAMP_RATELIMIT_CHAIN
${ICMP_TYPE_8_NFT_CHAIN}=      nft list chain ip filter INGRESS_ECHO_REQUEST
${ICMP_TYPE_3_NFT_CHAIN}=      nft list chain ip filter INGRESS_DEST_UNREACHABLE
${ICMP_TYPE_11_NFT_CHAIN}=     nft list chain ip filter INGRESS_TIME_EXCEEDED
${ICMP_TYPE_0_NFT_CHAIN}=      nft list chain ip filter INGRESS_ECHO_RESPONSE
${ICMP_TYPE_12_NFT_CHAIN}=     nft list chain ip filter INGRESS_PARAMETER_PROBLEM
${MPLANE_NFT_CHAIN}=           nft list chain ip filter RATELIMIT_CHAIN
${TWAMP_IPV6_NFT_CHAIN}=       nft list chain ip6 filter TWAMP_RATELIMIT_CHAIN

#M51328C14 (ipRmDropPcktsRtLim5GCplane) settings
${M51328C14_COUNTER}=              M51328C14
${M51328C14_LOOP}=                 500000
${M51328C14_PPS}=                  50000
${M51328C14_SPORT}=                38472
${M51328C14_DPORT}=                38472
${M51328C14_STATISTICAL_ERROR}=    ${M51328C14_LOOP} * 0.1

#M51328C7 (ipRmDropPcktsRtLimTwamp) settings

${M51328C7_COUNTER}=               M51328C7
${M51328C7_LOOP}=                  62000
${M51328C7_PPS}=                   6200
${M51328C7_DPORT}=                 5018
${M51328C7_STATISTICAL_ERROR}=     ${M51328C7_LOOP} * 0.1

#M51328C15 (ipRmDropPcktsRtLimICMP) settings

${M51328C15_COUNTER}=               M51328C15
${M51328C15_LOOP}=                  1000
${M51328C15_PPS}=                   100
${M51328C15_STATISTICAL_ERROR}=     ${M51328C7_LOOP} * 0.1
${M51328C15_ECHO_REQUEST_TYPE}=     8
${M51328C15_DEST_UNREACH_TYPE}=     3
${M51328C15_TIME_EXCEEDED_TYPE}=    11
${M51328C15_ECHO_REPLY_TYPE}=       0
${M51328C15_PARAM_PROBLEM_TYPE}=    12

#M51328C18 (ipRmDropPcktsRtLimMplane) settings

${M51328C18_COUNTER}=              M51328C18
${M51328C18_LOOP}=                 50000
${M51328C18_PPS}=                  5000
${M51328C18_STATISTICAL_ERROR}=    ${M51328C7_LOOP} * 0.1

@{PORTS}                            443  8080  8443
@{ICMP_TYPES}                       3  11  0  12

*** Keywords ***
Get Defined DistName Path
    [Documentation]    Description:      Returning a path to an object of a defined length (defined number of objects in the path).
    ...                                  Example of usage:
    ...                                  dist_name=MRBTS-8446/TNLSVC-1/TNL-6/IPNO-1/IPIF-1/IPADDRESSV4-1/IPADDRESSV4_R-1
    ...                                  lenght=4
    ...                                  Output:
    ...                                  specific_dist_path=MRBTS-8446/TNLSVC-1/TNL-6/IPNO-1
    ...                Return:           The path to object that was changed to specific length.
    ...                Author:           jagoda.kubacka@nokia.com
    ...                Modification:     14-05-2024 made by jagoda.kubacka@nokia.com
    [Arguments]        ${dist_name}      # The full path for specific parameter
    ...                ${length}         # Length that should have path (how many elements should have)
    ${path}=           Split String    ${dist_name}    /
    ${desired_path}=   Create List
    FOR    ${index}    IN RANGE    ${length}
        Append To List    ${desired_path}    ${path}[${index}]
        ${specific_dist_path}=    Evaluate    '/'.join(${desired_path})
    END
    [Return]    ${specific_dist_path}

Check If Proper Counter Is Increased
    [Documentation]    Description:      Checking if the proper counter is visible and traffic was collected
    ...                                  in the right interval. Firstly, the interval from parameter is collected.
    ...                                  The sleep_interval value is set to have the proper amount of loops that
    ...                                  must be done to have counter. Then, the time_after have the time of counter
    ...                                  that will collect dropped packages. In the loop, the availables counters are
    ...                                  compared to the time_after value because we need to wait for counter that
    ...                                  will have the collected, dropped traffic. If the available and defined
    ...                                  counter will be the same - that means the proper counter is visible on vCU/vDU
    ...                                  and value can be gathered and checked.
    ...                Return:           None
    ...                Author:           jagoda.kubacka@nokia.com
    ...                Modification:     14-05-2024 made by jagoda.kubacka@nokia.com
    [Arguments]        ${WebEM_time}     #the last counter that is visible on vDU/vCU
    ...                ${time_before}    #the execution time where scapy command was sent
    ...                ${counter_id}     #the ID of counter that must be checked
    ...                ${object}         #object of the specific counter
    ...                ${hw_type}        #vCU/vDU
    ${interval_value}=    Run Keyword If    '${hw_type}'=='vCU'    Check Parameter Value    ipFilteringInterval
    ...                                                            MRBTS-${MRBTS_CU}/TNLSVC-1/PMTNLINT-1    ${hw_type}
    ...    ELSE           Check Parameter Value    ipFilteringInterval
    ...                   MRBTS-${MRBTS}/TNLSVC-1/PMTNLINT-1    ${hw_type}
    ${sleep_interval}     Evaluate    (${value} * 2) + 1
    ${time_after}=        get_proper_interval    ${WebEM_time}    ${time_before}    ${value}
    FOR  ${i}  IN RANGE   0    ${sleep_interval}
        Log    Loop number: ${i} / ${sleep_interval}. Checking if expected counter is visible in progress...    console=true
        ${actual_time}=   Get Counters Time From WebEM on BTS    counter_id=${counter_id}
        ...                                                      object=${object}
        ...                                                      hw_type=${hw_type}
        Log    Wait for counter, present counter time is ${actual_time}, expected counter time is ${time_after}    console=true
        ${status}=        Run Keyword And Return Status    Should Be Equal    ${actual_time}    ${time_after}
        Exit For Loop If    '${status}' == 'True'
        Sleep    60    reason=Waiting a minute to get the new value of counter in next interval
    END

Get Random ICMP Type
    ${icmp_random_type}=    Evaluate    random.choice(${ICMP_TYPES})    random
    [Return]    ${icmp_random_type}
