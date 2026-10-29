*** Settings ***
Documentation   The features introduces a new classifier for the 5G M-plane traffic and
...             new separate rate limiters for the 5G M-plane traffic, which help to keep the M-plane
...             interfaces up when a DoS or DDoS attack is performed on IP addresses other than
...             the M-plane IP address. It also introduces a counter per rate limiter to help find the source
...             of a DoS/DDoS attack. This sub-feature is a parity feature to SRAN feature SR002103.

...             Test Case scenario author:     Maciej Nagly, Ewa Burnecka
...             Test Case scenario contact:    maciej.nagly@nokia.com, ewa.burnecka@nokia.com

...             Test Case automation author:   Mykhailo Yevchuk
...             Test Case automation contact:  mykhailo.yevchuk@nokia.com

Resource            ../Resources/Keywords.robot
Resource            ../../../common_resources/counters/counters_keywords.robot
Resource            ../../../common_resources/mantaray/mantaray.robot
Resource            ../Resources/Keywords.robot

Library    BuiltIn
*** Keywords ***

# <------------------------------------------ [1] ASIL + ABIO ------------------------------------------>
[1]CB007672-5G-A-Rate_Limit_for_UDP_echo_request_TWAMP_ipRmDropPcktsRtLimTwamp
    ${NMS_LAB}=    mantaray.Integrate BTS To MantaRay With TLS    PREFERRED_LAB=srnclab2010
    Set Test Variable    ${counter_id}    M51328C7
    ${pps_number}=   Keywords.Get ASIB Or ASIL PPS Number For Certain Counter  5
    ${burst_number}=   Keywords.Get ASIB Or ASIL Burst Number For Certain Counter  5
    Should Be True  ${pps_number} == ${M51328C7_LIMIT}
    Should Be True  ${burst_number} == ${M51328C7_BURST}
    log to console  pps number is correct: ${pps_number}
    log to console  burst number is correct: ${burst_number}
    ${admin_conn}=  Connect to ADMIN
    Delete IPAPP Object From BTS      ${admin_conn}
    Create IPAPP Object if doesn't Exist or Change Parameter               ${admin_conn}
    Create TWAMPREFLECT Object        ${admin_conn}
    Disconnect from ADMIN             ${admin_conn}
    Change Rejected Packets Interval and Reporting Interval parameters value to 5 minutes
    Run Keyword And Ignore Error  Check If There Are Any Transport Counter Issues And Reboot BTS If Neened  M51328C7
    Wait Until Transport Counters Available After Reboot  M51328C7
    Actualize NetAct Counters
    Wait For New Interval Start  M51328C7
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C7
    ${counter_WebEm_value_before}=  Get Counter Value From WebEm  M51328C7
    ${counter_NetAct_value_before}=  Get Counter Value From NetAct  M51328C7
    ${counter_SSH_value_before}=  Get Counter Value From BTS Via SSH For ASIL For Certain Counter  Twamp RL Counter
    Compare NetAct And WebEm Counter Time
    log  NetAct and WebEm counters time is correct  console=yes
    Remove NetAct Counters Raport
    log  counter value from WebEm before test is ${counter_WebEm_value_before}  console=yes
    log  counter value from NetAct before test is ${counter_NetAct_value_before}  console=yes
    log  counter value from BTS before test is ${counter_SSH_value_before}  console=yes
    Start Tcpdump For M51328C18 Or M51328C12 Or M51328C7 Counters
    Send Packets For M51328C7 Counter To BTS
    Kill Tcpdump For M51328C18 Or M51328C12 Or M51328C7 Counters
    log  packets were successfully sent on BTS with tcpdump  console=yes
    ${number_of_packets}=  Get Number Of Packets After Packets Flood
#    we should divide number of collected packets by two because of TWAMP two-way specific
    ${equation_scapy_more}=  Catenate  (${number_of_packets} / 2) > (${M51328C7_PACKETS} *
    ...  ${M51328C7_NUMBER_OF_SCAPY_RUNS} * ${M51328C7_TCPDUMP_STATISTICAL_ERROR_LESS})
    ${equation_scapy_less}=  Catenate  (${number_of_packets} / 2) < (${M51328C7_PACKETS} *
    ...  ${M51328C7_NUMBER_OF_SCAPY_RUNS} * ${M51328C7_TCPDUMP_STATISTICAL_ERROR_MORE})
    Should Be True  ${equation_scapy_more}
    Should Be True  ${equation_scapy_less}
    log  packets were successfully collected on BTS with tcpdump  console=yes
    Wait For New Interval Start  M51328C7
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C7
    ${counter_WebEm_value_after}=  Get Counter Value From WebEm  M51328C7
    ${counter_NetAct_value_after}=  Get Counter Value From NetAct  M51328C7
    ${counter_SSH_value_after}=  Get Counter Value From BTS Via SSH For ASIL For Certain Counter  Twamp RL Counter
    Compare NetAct And WebEm Counter Time
    Remove NetAct Counters Raport
    log  counter value from WebEm after test is ${counter_WebEm_value_after}  console=yes
    log  counter value from NetAct after test is ${counter_NetAct_value_after}  console=yes
    log  counter value from BTS after test is ${counter_SSH_value_after}  console=yes
    ${equation_WebEm}=  Catenate  (${counter_WebEm_value_after} - ${counter_WebEm_value_before} > ${M51328C7_SHOULD_BE_COLLECTED} -
    ...  ${M51328C7_TEST_STATISTICAL_ERROR}) and (${counter_WebEm_value_after} - ${counter_WebEm_value_before} <
    ...  ${M51328C7_SHOULD_BE_COLLECTED} + ${M51328C7_TEST_STATISTICAL_ERROR})
    ${equation_NetAct}=  Catenate  (${counter_NetAct_value_after} - ${counter_NetAct_value_before} > ${M51328C7_SHOULD_BE_COLLECTED} -
    ...  ${M51328C7_TEST_STATISTICAL_ERROR}) and (${counter_NetAct_value_after} - ${counter_NetAct_value_before} <
    ...  ${M51328C7_SHOULD_BE_COLLECTED} + ${M51328C7_TEST_STATISTICAL_ERROR})
    ${equation_SSH}=  Catenate  (${counter_SSH_value_after} - ${counter_SSH_value_before} > ${M51328C7_SHOULD_BE_COLLECTED} -
    ...  ${M51328C7_TEST_STATISTICAL_ERROR}) and (${counter_SSH_value_after} - ${counter_SSH_value_before} <
    ...  ${M51328C7_SHOULD_BE_COLLECTED} + ${M51328C7_TEST_STATISTICAL_ERROR})
    Should Be True  ${counter_WebEm_value_after} == ${counter_NetAct_value_after} == (${counter_SSH_value_after} - ${counter_SSH_value_before})
    Should Be True  ${equation_WebEm}
    Should Be True  ${equation_NetAct}
    Should Be True  ${equation_SSH}
    log  packets were successfully collected in M51328C7 transport counter on BTS  console=yes
    ${admin_conn}=  Connect to ADMIN
    Delete IPAPP Object From BTS      ${admin_conn}
    Disconnect from ADMIN             ${admin_conn}

[1]CB007672-5G-A-Rate_Limit_for_UDP_echo_request_TWAMP_ipRmDropPcktsRtLimTwamp_IPv6
    ${pps_number}=   Keywords.Get ASIB Or ASIL PPS Number For Certain Counter  5
    ${burst_number}=   Keywords.Get ASIB Or ASIL Burst Number For Certain Counter  5
    Should Be True  ${pps_number} == ${M51328C7_LIMIT}
    Should Be True  ${burst_number} == ${M51328C7_BURST}
    log to console  pps number is correct: ${pps_number}
    log to console  burst number is correct: ${burst_number}
    ${admin_conn}=  Connect to ADMIN
    Delete IPAPP Object From BTS      ${admin_conn}
    Create IPAPP Object if doesn't Exist or Change Parameter               ${admin_conn}
    Create TWAMPREFLECT Object        ${admin_conn}
    Disconnect from ADMIN             ${admin_conn}
    Change Rejected Packets Interval and Reporting Interval parameters value to 5 minutes
    Run Keyword And Ignore Error  Check If There Are Any Transport Counter Issues And Reboot BTS If Neened  M51328C7
    Wait Until Transport Counters Available After Reboot  M51328C7
    Actualize NetAct Counters
    Wait For New Interval Start  M51328C7
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C7
    ${counter_WebEm_value_before}=  Get Counter Value From WebEm  M51328C7
    ${counter_NetAct_value_before}=  Get Counter Value From NetAct  M51328C7
    ${counter_SSH_value_before}=  Get Counter Value From BTS Via SSH For ASIL For Certain Counter  Twamp RL Counter
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    log  NetAct and WebEm counters time is correct  console=yes
    Remove NetAct Counters Raport
    log  counter value from WebEm before test is ${counter_WebEm_value_before}  console=yes
    log  counter value from NetAct before test is ${counter_NetAct_value_before}  console=yes
    log  counter value from BTS before test is ${counter_SSH_value_before}  console=yes
    Start Tcpdump For M51328C18 Or M51328C12 Or M51328C7 Counters
    Send Packets For M51328C7 Counter To BTS IPv6
    Kill Tcpdump For M51328C18 Or M51328C12 Or M51328C7 Counters
    log  packets were successfully sent on BTS with tcpdump  console=yes
    ${number_of_packets}=  Get Number Of Packets After Packets Flood
#    we should divide number of collected packets by two because of TWAMP two-way specific
    ${equation_scapy_more}=  Catenate  (${number_of_packets} / 2) > (${M51328C7_PACKETS} *
    ...  ${M51328C7_NUMBER_OF_SCAPY_RUNS} * ${M51328C7_TCPDUMP_STATISTICAL_ERROR_LESS})
    ${equation_scapy_less}=  Catenate  (${number_of_packets} / 2) < (${M51328C7_PACKETS} *
    ...  ${M51328C7_NUMBER_OF_SCAPY_RUNS} * ${M51328C7_TCPDUMP_STATISTICAL_ERROR_MORE})
    Should Be True  ${equation_scapy_more}
    Should Be True  ${equation_scapy_less}
    log  packets were successfully collected on BTS with tcpdump  console=yes
    Wait For New Interval Start  M51328C7
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C7
    ${counter_WebEm_value_after}=  Get Counter Value From WebEm  M51328C7
    ${counter_NetAct_value_after}=  Get Counter Value From NetAct  M51328C7
    ${counter_SSH_value_after}=  Get Counter Value From BTS Via SSH For ASIL For Certain Counter  Twamp RL Counter
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    Remove NetAct Counters Raport
    log  counter value from WebEm after test is ${counter_WebEm_value_after}  console=yes
    log  counter value from NetAct after test is ${counter_NetAct_value_after}  console=yes
    log  counter value from BTS after test is ${counter_SSH_value_after}  console=yes
    ${equation_WebEm}=  Catenate  (${counter_WebEm_value_after} - ${counter_WebEm_value_before} > ${M51328C7_SHOULD_BE_COLLECTED} -
    ...  ${M51328C7_TEST_STATISTICAL_ERROR}) and (${counter_WebEm_value_after} - ${counter_WebEm_value_before} <
    ...  ${M51328C7_SHOULD_BE_COLLECTED} + ${M51328C7_TEST_STATISTICAL_ERROR})
    ${equation_NetAct}=  Catenate  (${counter_NetAct_value_after} - ${counter_NetAct_value_before} > ${M51328C7_SHOULD_BE_COLLECTED} -
    ...  ${M51328C7_TEST_STATISTICAL_ERROR}) and (${counter_NetAct_value_after} - ${counter_NetAct_value_before} <
    ...  ${M51328C7_SHOULD_BE_COLLECTED} + ${M51328C7_TEST_STATISTICAL_ERROR})
    ${equation_SSH}=  Catenate  (${counter_SSH_value_after} - ${counter_SSH_value_before} > ${M51328C7_SHOULD_BE_COLLECTED} -
    ...  ${M51328C7_TEST_STATISTICAL_ERROR}) and (${counter_SSH_value_after} - ${counter_SSH_value_before} <
    ...  ${M51328C7_SHOULD_BE_COLLECTED} + ${M51328C7_TEST_STATISTICAL_ERROR})
    Should Be True  ${counter_WebEm_value_after} == ${counter_NetAct_value_after} == (${counter_SSH_value_after} - ${counter_SSH_value_before})
    Should Be True  ${equation_WebEm}
    Should Be True  ${equation_NetAct}
    Should Be True  ${equation_SSH}
    log  packets were successfully collected in M51328C7 transport counter on BTS  console=yes
    ${admin_conn}=  Connect to ADMIN
    Delete IPAPP Object From BTS      ${admin_conn}
    Disconnect from ADMIN             ${admin_conn}

[1]CB007672-5G-A-Rate_Limit_for_TOP_ipRmDropPcktsRtLimSplane
    Set Test Variable    ${counter_id}    M51328C8
    ${pps_number}=   Keywords.Get ASIB Or ASIL PPS Number For Certain Counter  4
    ${burst_number}=   Keywords. Keywords. Or ASIL Burst Number For Certain Counter  4
    Should Be True  ${pps_number} == ${M51328C8_LIMIT}
    Should Be True  ${burst_number} == ${M51328C8_BURST}
    log to console  pps number is correct: ${pps_number}
    log to console  burst number is correct: ${burst_number}
    ${admin_conn}=  Connect to ADMIN
    ${original_S_Plane_IPNO_path}=  Get SPlaneIpAddressDN From BTS  ${admin_conn}
    ${original_master_IP_address}=  Get MasterIpAddress From BTS  ${admin_conn}
    ${S_Plane_IPNO_path}=  Get S_Plane IPv4 Address Path  ${admin_conn}
    ${source_ipv4_addr}=  Get Source IPv4 Address
    Change TOP MasterIpAddress On BTS  ${admin_conn}  ${source_ipv4_addr}
    Change SPlaneIpAddressDN On BTS  ${admin_conn}  ${S_Plane_IPNO_path}
    Disconnect from ADMIN       ${admin_conn}
    Change Rejected Packets Interval and Reporting Interval parameters value to 5 minutes
    Run Keyword And Ignore Error  Check If There Are Any Transport Counter Issues And Reboot BTS If Neened  M51328C8
    Wait Until Transport Counters Available After Reboot  M51328C8
    Actualize NetAct Counters
    Wait For New Interval Start  M51328C8
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C8
    ${counter_WebEm_value_before}=  Get Counter Value From WebEm  M51328C8
    ${counter_NetAct_value_before}=  Get Counter Value From NetAct  M51328C8
    ${counter_SSH_value_before}=  Get Counter Value From BTS Via SSH For ASIL For Certain Counter  Splane RL Counter
    Compare NetAct And WebEm Counter Time
    log  NetAct and WebEm counters time is correct  console=yes
    Remove NetAct Counters Raport
    log  counter value from WebEm before test is ${counter_WebEm_value_before}  console=yes
    log  counter value from NetAct before test is ${counter_NetAct_value_before}  console=yes
    log  counter value from BTS before test is ${counter_SSH_value_before}  console=yes
    ${master_ip_addr}=  Get Source IPv4 Address
    Start Tcpdump For M51328C8 Counter  ${master_ip_addr}
    Send Packets For M51328C8 Counter To BTS  ${master_ip_addr}
    Kill Tcpdump For M51328C8 Counter  ${master_ip_addr}
    log  packets were successfully sent on BTS with tcpdump  console=yes
    ${number_of_packets}=  Get Number Of Packets After Packets Flood
    Should Be True  ${number_of_packets} > (${M51328C8_PACKETS} * ${M51328C8_TCPDUMP_STATISTICAL_ERROR_LESS})
    Should Be True  ${number_of_packets} < (${M51328C8_PACKETS} * ${M51328C8_TCPDUMP_STATISTICAL_ERROR_MORE})
    log  packets were successfully collected on BTS with tcpdump  console=yes
    Wait For New Interval Start  M51328C8
    Sleep     240s
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C8
    ${counter_WebEm_value_after}=  Get Counter Value From WebEm  M51328C8
    ${counter_NetAct_value_after}=  Get Counter Value From NetAct  M51328C8
    ${counter_SSH_value_after}=  Get Counter Value From BTS Via SSH For ASIL For Certain Counter  Splane RL Counter
    Compare NetAct And WebEm Counter Time
    Remove NetAct Counters Raport
    log  counter value from WebEm after test is ${counter_WebEm_value_after}  console=yes
    log  counter value from NetAct after test is ${counter_NetAct_value_after}  console=yes
    log  counter value from BTS after test is ${counter_SSH_value_after}  console=yes
    ${equation_WebEm}=  Catenate  (${counter_WebEm_value_after} - ${counter_WebEm_value_before} > ${M51328C8_SHOULD_BE_COLLECTED} -
    ...  ${M51328C8_TEST_STATISTICAL_ERROR}) and (${counter_WebEm_value_after} - ${counter_WebEm_value_before} <
    ...  ${M51328C8_SHOULD_BE_COLLECTED} + ${M51328C8_TEST_STATISTICAL_ERROR})
    ${equation_NetAct}=  Catenate  (${counter_NetAct_value_after} - ${counter_NetAct_value_before} > ${M51328C8_SHOULD_BE_COLLECTED} -
    ...  ${M51328C8_TEST_STATISTICAL_ERROR}) and (${counter_NetAct_value_after} - ${counter_NetAct_value_before} <
    ...  ${M51328C8_SHOULD_BE_COLLECTED} + ${M51328C8_TEST_STATISTICAL_ERROR})
    ${equation_SSH}=  Catenate  (${counter_SSH_value_after} - ${counter_SSH_value_before} > ${M51328C8_SHOULD_BE_COLLECTED} -
    ...  ${M51328C8_TEST_STATISTICAL_ERROR}) and (${counter_SSH_value_after} - ${counter_SSH_value_before} <
    ...  ${M51328C8_SHOULD_BE_COLLECTED} + ${M51328C8_TEST_STATISTICAL_ERROR})
    Should Be True  ${counter_WebEm_value_after} == ${counter_NetAct_value_after} == (${counter_SSH_value_after} - ${counter_SSH_value_before})
    Should Be True  ${equation_WebEm}
    Should Be True  ${equation_NetAct}
    Should Be True  ${equation_SSH}
    log  packets were successfully collected in M51328C8 transport counter on BTS  console=yes
    ${admin_conn}=  Connect to ADMIN
    Change TOP MasterIpAddress On BTS  ${admin_conn}  ${original_master_IP_address}
    Change SPlaneIpAddressDN On BTS  ${admin_conn}  ${original_S_Plane_IPNO_path}
    Wait until BTS reach Configured or OnAir state

[1]CB007672-5G-A-Rate_Limit_for_TOP_ipRmDropPcktsRtLimSplane_IPv6
    ${pps_number}=   Keywords.Get ASIB Or ASIL PPS Number For Certain Counter  4
    ${burst_number}=  Get ASIB Or ASIL Burst Number For Certain Counter  4
    Should Be True  ${pps_number} == ${M51328C8_LIMIT}
    Should Be True  ${burst_number} == ${M51328C8_BURST}
    log to console  pps number is correct: ${pps_number}
    log to console  burst number is correct: ${burst_number}
    ${admin_conn}=  Connect to ADMIN
    ${original_S_Plane_IPNO_path}=  Get SPlaneIpAddressDN From BTS  ${admin_conn}
    ${original_master_IP_address}=  Get MasterIpAddress From BTS  ${admin_conn}
    ${S_Plane_IPNO_path}=  Get S_Plane IPv6 Address Path  ${admin_conn}
    ${source_ipv6_addr}=  Get Source IPv6 Address
    Change TOP MasterIpAddress On BTS  ${admin_conn}  ${source_ipv6_addr}
    Change SPlaneIpAddressDN On BTS  ${admin_conn}  ${S_Plane_IPNO_path}
    Disconnect from ADMIN       ${admin_conn}
    Change Rejected Packets Interval and Reporting Interval parameters value to 5 minutes
    Run Keyword And Ignore Error  Check If There Are Any Transport Counter Issues And Reboot BTS If Neened  M51328C8
    Wait Until Transport Counters Available After Reboot  M51328C8
    Actualize NetAct Counters
    Wait For New Interval Start  M51328C8
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C8
    ${counter_WebEm_value_before}=  Keywords.Get Counter Value From WebEm  M51328C8
    ${counter_NetAct_value_before}=  Keywords.Get Counter Value From NetAct  M51328C8
    ${counter_SSH_value_before}=  Keywords.Get Counter Value From BTS Via SSH For ASIL For Certain Counter  Splane RL Counter
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    log  NetAct and WebEm counters time is correct  console=yes
    Remove NetAct Counters Raport
    log  counter value from WebEm before test is ${counter_WebEm_value_before}  console=yes
    log  counter value from NetAct before test is ${counter_NetAct_value_before}  console=yes
    log  counter value from BTS before test is ${counter_SSH_value_before}  console=yes
    ${master_ip_addr}=  Get Source IPv6 Address
    Start Tcpdump For M51328C8 Counter  ${master_ip_addr}
    Send Packets For M51328C8 Counter To BTS IPv6  ${master_ip_addr}
    Kill Tcpdump For M51328C8 Counter  ${master_ip_addr}
    log  packets were successfully sent on BTS with tcpdump  console=yes
    ${number_of_packets}=  Get Number Of Packets After Packets Flood
    Should Be True  ${number_of_packets} > (${M51328C8_PACKETS} * ${M51328C8_TCPDUMP_STATISTICAL_ERROR_LESS})
    Should Be True  ${number_of_packets} < (${M51328C8_PACKETS} * ${M51328C8_TCPDUMP_STATISTICAL_ERROR_MORE})
    log  packets were successfully collected on BTS with tcpdump  console=yes
    Wait For New Interval Start  M51328C8
    ${WebEm_counter_time}=  Keywords.Get Counter Time From WebEm  M51328C8
    ${counter_WebEm_value_after}=  Keywords.Get Counter Value From WebEm  M51328C8
    ${counter_NetAct_value_after}=  Keywords.Get Counter Value From NetAct  M51328C8
    ${counter_SSH_value_after}=  Keywords.Get Counter Value From BTS Via SSH For ASIL For Certain Counter  Splane RL Counter
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    Remove NetAct Counters Raport
    log  counter value from WebEm after test is ${counter_WebEm_value_after}  console=yes
    log  counter value from NetAct after test is ${counter_NetAct_value_after}  console=yes
    log  counter value from BTS after test is ${counter_SSH_value_after}  console=yes
    ${equation_WebEm}=  Catenate  (${counter_WebEm_value_after} - ${counter_WebEm_value_before} > ${M51328C8_SHOULD_BE_COLLECTED} -
    ...  ${M51328C8_TEST_STATISTICAL_ERROR}) and (${counter_WebEm_value_after} - ${counter_WebEm_value_before} <
    ...  ${M51328C8_SHOULD_BE_COLLECTED} + ${M51328C8_TEST_STATISTICAL_ERROR})
    ${equation_NetAct}=  Catenate  (${counter_NetAct_value_after} - ${counter_NetAct_value_before} > ${M51328C8_SHOULD_BE_COLLECTED} -
    ...  ${M51328C8_TEST_STATISTICAL_ERROR}) and (${counter_NetAct_value_after} - ${counter_NetAct_value_before} <
    ...  ${M51328C8_SHOULD_BE_COLLECTED} + ${M51328C8_TEST_STATISTICAL_ERROR})
    ${equation_SSH}=  Catenate  (${counter_SSH_value_after} - ${counter_SSH_value_before} > ${M51328C8_SHOULD_BE_COLLECTED} -
    ...  ${M51328C8_TEST_STATISTICAL_ERROR}) and (${counter_SSH_value_after} - ${counter_SSH_value_before} <
    ...  ${M51328C8_SHOULD_BE_COLLECTED} + ${M51328C8_TEST_STATISTICAL_ERROR})
    Should Be True  ${counter_WebEm_value_after} == ${counter_NetAct_value_after} == (${counter_SSH_value_after} - ${counter_SSH_value_before})
    Should Be True  ${equation_WebEm}
    Should Be True  ${equation_NetAct}
    Should Be True  ${equation_SSH}
    log  packets were successfully collected in M51328C8 transport counter on BTS  console=yes
    ${admin_conn}=  Connect to ADMIN
    Change TOP MasterIpAddress On BTS  ${admin_conn}  ${original_master_IP_address}
    Change SPlaneIpAddressDN On BTS  ${admin_conn}  ${original_S_Plane_IPNO_path}
    Wait until BTS reach Configured or OnAir state

[1]CB007672-5G-A-Rate_Limit_for_M-plane_LTE_ipRmDropPcktsRtLimSrLteMplane
    ${counter_id_status}=  Run Keyword And Ignore Error  Get Counter Value From WebEm  M51328C18
    ${counter_id}=  Set Variable If  'PASS' in ${counter_id_status}  M51328C18  M51328C11
    Set Test Variable    ${counter_id}
    ${pps_number}=   Keywords.Get ASIB Or ASIL PPS Number For Certain Counter  6
    ${burst_number}=  Get ASIB Or ASIL Burst Number For Certain Counter  6
    Should Be True  ${pps_number} == ${M51328C18_LIMIT}
    Should Be True  ${burst_number} == ${M51328C18_BURST}
    log to console  pps number is correct: ${pps_number}
    log to console  burst number is correct: ${burst_number}
    Change Rejected Packets Interval and Reporting Interval parameters value to 5 minutes
    Run Keyword And Ignore Error  Check If There Are Any Transport Counter Issues And Reboot BTS If Neened  ${counter_id}
    Wait Until Transport Counters Available After Reboot  ${counter_id}
    Actualize NetAct Counters
    Wait For New Interval Start  ${counter_id}
    ${WebEm_counter_time}=  Get Counter Time From WebEm  ${counter_id}
    ${counter_WebEm_value_before}=  Get Counter Value From WebEm  ${counter_id}
    ${counter_NetAct_value_before}=  Get Counter Value From NetAct  ${counter_id}
    ${counter_SSH_value_before}=  Get Counter Value From BTS Via SSH For ASIL For Certain Counter  Mplane RL Counter
    Compare NetAct And WebEm Counter Time
    log  NetAct and WebEm counters time is correct  console=yes
    Remove NetAct Counters Raport
    log  counter value from WebEm before test is ${counter_WebEm_value_before}  console=yes
    log  counter value from NetAct before test is ${counter_NetAct_value_before}  console=yes
    log  counter value from BTS before test is ${counter_SSH_value_before}  console=yes
    Start Tcpdump For M51328C18 Or M51328C12 Or M51328C7 Counters
    Send Packets For M51328C18 Counter To BTS
    Kill Tcpdump For M51328C18 Or M51328C12 Or M51328C7 Counters
    log  packets were successfully sent on BTS with tcpdump  console=yes
    ${number_of_packets}=  Get Number Of Packets After Packets Flood
    Should Be True  ${number_of_packets} > (${M51328C18_PACKETS} * ${M51328C18_TCPDUMP_STATISTICAL_ERROR_LESS})
    Should Be True  ${number_of_packets} < (${M51328C18_PACKETS} * ${M51328C18_TCPDUMP_STATISTICAL_ERROR_MORE})
    log  packets were successfully collected on BTS with tcpdump  console=yes
    Wait For New Interval Start  ${counter_id}
    Sleep     240s
    ${WebEm_counter_time}=  Get Counter Time From WebEm  ${counter_id}
    ${counter_WebEm_value_after}=  Get Counter Value From WebEm  ${counter_id}
    ${counter_NetAct_value_after}=  Get Counter Value From NetAct  ${counter_id}
    ${counter_SSH_value_after}=  Get Counter Value From BTS Via SSH For ASIL For Certain Counter  Mplane RL Counter
    Compare NetAct And WebEm Counter Time
    Remove NetAct Counters Raport
    log  counter value from WebEm after test is ${counter_WebEm_value_after}  console=yes
    log  counter value from NetAct after test is ${counter_NetAct_value_after}  console=yes
    log  counter value from BTS after test is ${counter_SSH_value_after}  console=yes
    ${equation_WebEm}=  Catenate  (${counter_WebEm_value_after} - ${counter_WebEm_value_before} > ${M51328C18_SHOULD_BE_COLLECTED} -
    ...  ${M51328C18_TEST_STATISTICAL_ERROR}) and (${counter_WebEm_value_after} - ${counter_WebEm_value_before} <
    ...  ${M51328C18_SHOULD_BE_COLLECTED} + ${M51328C18_TEST_STATISTICAL_ERROR})
    ${equation_NetAct}=  Catenate  (${counter_NetAct_value_after} - ${counter_NetAct_value_before} > ${M51328C18_SHOULD_BE_COLLECTED} -
    ...  ${M51328C18_TEST_STATISTICAL_ERROR}) and (${counter_NetAct_value_after} - ${counter_NetAct_value_before} <
    ...  ${M51328C18_SHOULD_BE_COLLECTED} + ${M51328C18_TEST_STATISTICAL_ERROR})
    ${equation_SSH}=  Catenate  (${counter_SSH_value_after} - ${counter_SSH_value_before} > ${M51328C18_SHOULD_BE_COLLECTED} -
    ...  ${M51328C18_TEST_STATISTICAL_ERROR}) and (${counter_SSH_value_after} - ${counter_SSH_value_before} <
    ...  ${M51328C18_SHOULD_BE_COLLECTED} + ${M51328C18_TEST_STATISTICAL_ERROR})
    Should Be True  ${counter_WebEm_value_after} == ${counter_NetAct_value_after} == (${counter_SSH_value_after} - ${counter_SSH_value_before})
    Should Be True  ${equation_WebEm}
    Should Be True  ${equation_NetAct}
    Should Be True  ${equation_SSH}
    log  packets were successfully collected in ${counter_id} transport counter on BTS  console=yes

[1]CB007672-5G-A-Rate_Limit_for_M-plane_LTE_ipRmDropPcktsRtLimSrLteMplane_IPv6
    ${counter_id_status}=  Run Keyword And Ignore Error  Get Counter Value From WebEm  M51328C18
    ${counter_id}=  Set Variable If  'PASS' in ${counter_id_status}  M51328C18  M51328C11
    Set Test Variable    ${counter_id}
    ${pps_number}=   Keywords.Get ASIB Or ASIL PPS Number For Certain Counter  6
    ${burst_number}=  Get ASIB Or ASIL Burst Number For Certain Counter  6
    Should Be True  ${pps_number} == ${M51328C18_LIMIT}
    Should Be True  ${burst_number} == ${M51328C18_BURST}
    log to console  pps number is correct: ${pps_number}
    log to console  burst number is correct: ${burst_number}
    Change Rejected Packets Interval and Reporting Interval parameters value to 5 minutes
    Run Keyword And Ignore Error  Check If There Are Any Transport Counter Issues And Reboot BTS If Neened  ${counter_id}
    Wait Until Transport Counters Available After Reboot  ${counter_id}
    Actualize NetAct Counters
    Wait For New Interval Start  ${counter_id}
    ${WebEm_counter_time}=  Get Counter Time From WebEm  ${counter_id}
    ${counter_WebEm_value_before}=  Get Counter Value From WebEm  ${counter_id}
    ${counter_NetAct_value_before}=  Get Counter Value From NetAct  ${counter_id}
    ${counter_SSH_value_before}=  Get Counter Value From BTS Via SSH For ASIL For Certain Counter  Mplane RL Counter
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    log  NetAct and WebEm counters time is correct  console=yes
    Remove NetAct Counters Raport
    log  counter value from WebEm before test is ${counter_WebEm_value_before}  console=yes
    log  counter value from NetAct before test is ${counter_NetAct_value_before}  console=yes
    log  counter value from BTS before test is ${counter_SSH_value_before}  console=yes
    Start Tcpdump For M51328C18 Or M51328C12 Or M51328C7 Counters
    Send Packets For M51328C18 Counter To BTS IPv6
    Kill Tcpdump For M51328C18 Or M51328C12 Or M51328C7 Counters
    log  packets were successfully sent on BTS with tcpdump  console=yes
    ${number_of_packets}=  Get Number Of Packets After Packets Flood
    Should Be True  ${number_of_packets} > (${M51328C18_PACKETS} * ${M51328C18_TCPDUMP_STATISTICAL_ERROR_LESS})
    Should Be True  ${number_of_packets} < (${M51328C18_PACKETS} * ${M51328C18_TCPDUMP_STATISTICAL_ERROR_MORE})
    log  packets were successfully collected on BTS with tcpdump  console=yes
    Wait For New Interval Start  ${counter_id}
    ${WebEm_counter_time}=  Get Counter Time From WebEm  ${counter_id}
    ${counter_WebEm_value_after}=  Get Counter Value From WebEm  ${counter_id}
    ${counter_NetAct_value_after}=  Get Counter Value From NetAct  ${counter_id}
    ${counter_SSH_value_after}=  Get Counter Value From BTS Via SSH For ASIL For Certain Counter  Mplane RL Counter
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    Remove NetAct Counters Raport
    log  counter value from WebEm after test is ${counter_WebEm_value_after}  console=yes
    log  counter value from NetAct after test is ${counter_NetAct_value_after}  console=yes
    log  counter value from BTS after test is ${counter_SSH_value_after}  console=yes
    ${equation_WebEm}=  Catenate  (${counter_WebEm_value_after} - ${counter_WebEm_value_before} > ${M51328C18_SHOULD_BE_COLLECTED} -
    ...  ${M51328C18_TEST_STATISTICAL_ERROR}) and (${counter_WebEm_value_after} - ${counter_WebEm_value_before} <
    ...  ${M51328C18_SHOULD_BE_COLLECTED} + ${M51328C18_TEST_STATISTICAL_ERROR})
    ${equation_NetAct}=  Catenate  (${counter_NetAct_value_after} - ${counter_NetAct_value_before} > ${M51328C18_SHOULD_BE_COLLECTED} -
    ...  ${M51328C18_TEST_STATISTICAL_ERROR}) and (${counter_NetAct_value_after} - ${counter_NetAct_value_before} <
    ...  ${M51328C18_SHOULD_BE_COLLECTED} + ${M51328C18_TEST_STATISTICAL_ERROR})
    ${equation_SSH}=  Catenate  (${counter_SSH_value_after} - ${counter_SSH_value_before} > ${M51328C18_SHOULD_BE_COLLECTED} -
    ...  ${M51328C18_TEST_STATISTICAL_ERROR}) and (${counter_SSH_value_after} - ${counter_SSH_value_before} <
    ...  ${M51328C18_SHOULD_BE_COLLECTED} + ${M51328C18_TEST_STATISTICAL_ERROR})
    Should Be True  ${counter_WebEm_value_after} == ${counter_NetAct_value_after} == (${counter_SSH_value_after} - ${counter_SSH_value_before})
    Should Be True  ${equation_WebEm}
    Should Be True  ${equation_NetAct}
    Should Be True  ${equation_SSH}
    log  packets were successfully collected in ${counter_id} transport counter on BTS  console=yes

[1]CB007672-5G-A-Rate_Limit_for_Other_Non-M-plane_IP_ipRmDropPcktsRtLimDefault
    ${pps_number}=   Keywords.Get ASIB Or ASIL PPS Number For Certain Counter  18
    ${burst_number}=  Get ASIB Or ASIL Burst Number For Certain Counter  18
    Should Be True  ${pps_number} == ${M51328C12_LIMIT}
    Should Be True  ${burst_number} == ${M51328C12_BURST}
    log to console  pps number is correct: ${pps_number}
    log to console  burst number is correct: ${burst_number}
    Change Rejected Packets Interval and Reporting Interval parameters value to 5 minutes
    Run Keyword And Ignore Error  Check If There Are Any Transport Counter Issues And Reboot BTS If Neened  M51328C12
    Wait Until Transport Counters Available After Reboot  M51328C12
    Actualize NetAct Counters
    Wait For New Interval Start  M51328C12
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C12
    ${counter_WebEm_value_before}=  Get Counter Value From WebEm  M51328C12
    ${counter_NetAct_value_before}=  Get Counter Value From NetAct  M51328C12
    ${counter_SSH_value_before}=  Get Counter Value From BTS Via SSH For ASIL For Certain Counter  Default RL Counter
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    log  NetAct and WebEm counters time is correct  console=yes
    Remove NetAct Counters Raport
    log  counter value from WebEm before test is ${counter_WebEm_value_before}  console=yes
    log  counter value from NetAct before test is ${counter_NetAct_value_before}  console=yes
    log  counter value from BTS before test is ${counter_SSH_value_before}  console=yes
    Start Tcpdump For M51328C18 Or M51328C12 Or M51328C7 Counters
    Send Packets For M51328C12 Counter To BTS
    Kill Tcpdump For M51328C18 Or M51328C12 Or M51328C7 Counters
    log  packets were successfully sent on BTS with tcpdump  console=yes
    ${number_of_packets}=  Get Number Of Packets After Packets Flood
    Should Be True  ${number_of_packets} > (${M51328C12_PACKETS} * ${M51328C12_TCPDUMP_STATISTICAL_ERROR_LESS})
    Should Be True  ${number_of_packets} < (${M51328C12_PACKETS} * ${M51328C12_TCPDUMP_STATISTICAL_ERROR_MORE})
    log  packets were successfully collected on BTS with tcpdump  console=yes
    Wait For New Interval Start  M51328C12
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C12
    ${counter_WebEm_value_after}=  Get Counter Value From WebEm  M51328C12
    ${counter_NetAct_value_after}=  Get Counter Value From NetAct  M51328C12
    ${counter_SSH_value_after}=  Get Counter Value From BTS Via SSH For ASIL For Certain Counter  Default RL Counter
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    Remove NetAct Counters Raport
    log  counter value from WebEm after test is ${counter_WebEm_value_after}  console=yes
    log  counter value from NetAct after test is ${counter_NetAct_value_after}  console=yes
    log  counter value from BTS after test is ${counter_SSH_value_after}  console=yes
    ${equation_WebEm}=  Catenate  (${counter_WebEm_value_after} - ${counter_WebEm_value_before} > ${M51328C12_SHOULD_BE_COLLECTED} -
    ...  ${M51328C12_TEST_STATISTICAL_ERROR}) and (${counter_WebEm_value_after} - ${counter_WebEm_value_before} <
    ...  ${M51328C12_SHOULD_BE_COLLECTED} + ${M51328C12_TEST_STATISTICAL_ERROR})
    ${equation_NetAct}=  Catenate  (${counter_NetAct_value_after} - ${counter_NetAct_value_before} > ${M51328C12_SHOULD_BE_COLLECTED} -
    ...  ${M51328C12_TEST_STATISTICAL_ERROR}) and (${counter_NetAct_value_after} - ${counter_NetAct_value_before} <
    ...  ${M51328C12_SHOULD_BE_COLLECTED} + ${M51328C12_TEST_STATISTICAL_ERROR})
    ${equation_SSH}=  Catenate  (${counter_SSH_value_after} - ${counter_SSH_value_before} > ${M51328C12_SHOULD_BE_COLLECTED} -
    ...  ${M51328C12_TEST_STATISTICAL_ERROR}) and (${counter_SSH_value_after} - ${counter_SSH_value_before} <
    ...  ${M51328C12_SHOULD_BE_COLLECTED} + ${M51328C12_TEST_STATISTICAL_ERROR})
    Should Be True  ${counter_WebEm_value_after} == ${counter_NetAct_value_after} == (${counter_SSH_value_after} - ${counter_SSH_value_before})
    Should Be True  ${equation_WebEm}
    Should Be True  ${equation_NetAct}
    Should Be True  ${equation_SSH}
    log  packets were successfully collected in M51328C12 transport counter on BTS  console=yes

[1]CB007672-5G-A-Rate_Limit_for_Other_Non-M-plane_IP_ipRmDropPcktsRtLimDefault_IPv6
    Set Test Variable    ${counter_id}    M51328C12
    ${IPv6_addres}=    RUN  netstat -6 -rn | grep /120 | awk '/^::|:/ {print $1}' | cut -d'/' -f1
    ${IPv6_route}=     get_ipv6_route      ipv6_address=${IPv6_addres}
    RUN     sudo ip -6 route add default via ${IPv6_route} dev eth0
    ${pps_number}=   Keywords.Get ASIB Or ASIL PPS Number For Certain Counter  18
    ${burst_number}=   Keywords.Get ASIB Or ASIL Burst Number For Certain Counter  18
    Should Be True  ${pps_number} == ${M51328C12_LIMIT}
    Should Be True  ${burst_number} == ${M51328C12_BURST}
    log to console  pps number is correct: ${pps_number}
    log to console  burst number is correct: ${burst_number}
    Change Rejected Packets Interval and Reporting Interval parameters value to 5 minutes
    Run Keyword And Ignore Error  Check If There Are Any Transport Counter Issues And Reboot BTS If Neened  M51328C12
    Wait Until Transport Counters Available After Reboot  M51328C12
    Actualize NetAct Counters
    Wait For New Interval Start  M51328C12
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C12
    ${counter_WebEm_value_before}=  Get Counter Value From WebEm  M51328C12
    ${counter_NetAct_value_before}=  Get Counter Value From NetAct  M51328C12
    ${counter_SSH_value_before}=  Get Counter Value From BTS Via SSH For ASIL For Certain Counter  Default RL Counter
    Compare NetAct And WebEm Counter Time
    log  NetAct and WebEm counters time is correct  console=yes
    Remove NetAct Counters Raport
    log  counter value from WebEm before test is ${counter_WebEm_value_before}  console=yes
    log  counter value from NetAct before test is ${counter_NetAct_value_before}  console=yes
    log  counter value from BTS before test is ${counter_SSH_value_before}  console=yes
    Start Tcpdump For M51328C18 Or M51328C12 Or M51328C7 Counters
    Send Packets For M51328C12 Counter To BTS IPv6
    Kill Tcpdump For M51328C18 Or M51328C12 Or M51328C7 Counters
    log  packets were successfully sent on BTS with tcpdump  console=yes
    ${number_of_packets}=  Get Number Of Packets After Packets Flood
    Should Be True  ${number_of_packets} > (${M51328C12_PACKETS} * ${M51328C12_TCPDUMP_STATISTICAL_ERROR_LESS})
    Should Be True  ${number_of_packets} < (${M51328C12_PACKETS} * ${M51328C12_TCPDUMP_STATISTICAL_ERROR_MORE})
    log  packets were successfully collected on BTS with tcpdump  console=yes
    Wait For New Interval Start  M51328C12
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C12
    ${counter_WebEm_value_after}=  Get Counter Value From WebEm  M51328C12
    ${counter_NetAct_value_after}=  Get Counter Value From NetAct  M51328C12
    ${counter_SSH_value_after}=  Get Counter Value From BTS Via SSH For ASIL For Certain Counter  Default RL Counter
    Compare NetAct And WebEm Counter Time
    Remove NetAct Counters Raport
    log  counter value from WebEm after test is ${counter_WebEm_value_after}  console=yes
    log  counter value from NetAct after test is ${counter_NetAct_value_after}  console=yes
    log  counter value from BTS after test is ${counter_SSH_value_after}  console=yes
    ${equation_WebEm}=  Catenate  (${counter_WebEm_value_after} - ${counter_WebEm_value_before} > ${M51328C12_SHOULD_BE_COLLECTED} -
    ...  ${M51328C12_TEST_STATISTICAL_ERROR}) and (${counter_WebEm_value_after} - ${counter_WebEm_value_before} <
    ...  ${M51328C12_SHOULD_BE_COLLECTED} + ${M51328C12_TEST_STATISTICAL_ERROR})
    ${equation_NetAct}=  Catenate  (${counter_NetAct_value_after} - ${counter_NetAct_value_before} > ${M51328C12_SHOULD_BE_COLLECTED} -
    ...  ${M51328C12_TEST_STATISTICAL_ERROR}) and (${counter_NetAct_value_after} - ${counter_NetAct_value_before} <
    ...  ${M51328C12_SHOULD_BE_COLLECTED} + ${M51328C12_TEST_STATISTICAL_ERROR})
    ${equation_SSH}=  Catenate  (${counter_SSH_value_after} - ${counter_SSH_value_before} > ${M51328C12_SHOULD_BE_COLLECTED} -
    ...  ${M51328C12_TEST_STATISTICAL_ERROR}) and (${counter_SSH_value_after} - ${counter_SSH_value_before} <
    ...  ${M51328C12_SHOULD_BE_COLLECTED} + ${M51328C12_TEST_STATISTICAL_ERROR})
    Should Be True  ${counter_WebEm_value_after} == ${counter_NetAct_value_after} == (${counter_SSH_value_after} - ${counter_SSH_value_before})
    Should Be True  ${equation_WebEm}
    Should Be True  ${equation_NetAct}
    Should Be True  ${equation_SSH}
    log  packets were successfully collected in M51328C12 transport counter on BTS  console=yes

[1]CB007672-5G-A-Rate_Limit_for_5G_C-Plane_ipRmDropPcktsRtLim5GCplane
    Set Test Variable    ${counter_id}    M51328C14
    ${pps_number}=   Keywords.Get ASIB Or ASIL PPS Number For Certain Counter  11
    ${burst_number}=   Keywords.Get ASIB Or ASIL Burst Number For Certain Counter  11
    Should Be True  ${pps_number} == ${M51328C14_LIMIT}
    Should Be True  ${burst_number} == ${M51328C14_BURST} or ${burst_number} == ${M51328C14_BURST_SECOND_FOR_ASIL}
    log to console  pps number is correct: ${pps_number}
    log to console  burst number is correct: ${burst_number}
    Change Rejected Packets Interval and Reporting Interval parameters value to 5 minutes
    Run Keyword And Ignore Error  Check If There Are Any Transport Counter Issues And Reboot BTS If Neened  M51328C14
    Wait Until Transport Counters Available After Reboot  M51328C14
    Actualize NetAct Counters
    Wait For New Interval Start  M51328C14
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C14
    ${counter_WebEm_value_before}=  Get Counter Value From WebEm  M51328C14
    ${counter_NetAct_value_before}=  Get Counter Value From NetAct  M51328C14
    ${counter_SSH_value_before}=  Get Counter Value From BTS Via SSH For ASIL For Certain Counter  5GCplane RL Counter
    Compare NetAct And WebEm Counter Time
    log  NetAct and WebEm counters time is correct  console=yes
    Remove NetAct Counters Raport
    log  counter value from WebEm before test is ${counter_WebEm_value_before}  console=yes
    log  counter value from NetAct before test is ${counter_NetAct_value_before}  console=yes
    log  counter value from BTS before test is ${counter_SSH_value_before}  console=yes
    Start Tcpdump For M51328C14 Counter
    Send Packets For M51328C14 Counter To BTS
    Kill Tcpdump For M51328C14 Counter
    log  packets were successfully sent on BTS with tcpdump  console=yes
    ${number_of_packets}=  Get Number Of Packets After Packets Flood
    Should Be True  ${number_of_packets} > (${M51328C14_PACKETS} * ${M51328C14_TCPDUMP_STATISTICAL_ERROR_LESS})
    Should Be True  ${number_of_packets} < (${M51328C14_PACKETS} * ${M51328C14_TCPDUMP_STATISTICAL_ERROR_MORE})
    log  packets were successfully collected on BTS with tcpdump  console=yes
    Wait For New Interval Start  M51328C14
    Sleep     240s
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C14
    ${counter_WebEm_value_after}=  Get Counter Value From WebEm  M51328C14
    ${counter_NetAct_value_after}=  Get Counter Value From NetAct  M51328C14
    ${counter_SSH_value_after}=  Get Counter Value From BTS Via SSH For ASIL For Certain Counter  5GCplane RL Counter
    Compare NetAct And WebEm Counter Time
    Remove NetAct Counters Raport
    log  counter value from WebEm after test is ${counter_WebEm_value_after}  console=yes
    log  counter value from NetAct after test is ${counter_NetAct_value_after}  console=yes
    log  counter value from BTS after test is ${counter_SSH_value_after}  console=yes
    ${equation_WebEm}=  Catenate  (${counter_WebEm_value_after} - ${counter_WebEm_value_before} > ${M51328C14_SHOULD_BE_COLLECTED} -
    ...  ${M51328C14_TEST_STATISTICAL_ERROR}) and (${counter_WebEm_value_after} - ${counter_WebEm_value_before} <
    ...  ${M51328C14_SHOULD_BE_COLLECTED} + ${M51328C14_TEST_STATISTICAL_ERROR})
    ${equation_NetAct}=  Catenate  (${counter_NetAct_value_after} - ${counter_NetAct_value_before} > ${M51328C14_SHOULD_BE_COLLECTED} -
    ...  ${M51328C14_TEST_STATISTICAL_ERROR}) and (${counter_NetAct_value_after} - ${counter_NetAct_value_before} <
    ...  ${M51328C14_SHOULD_BE_COLLECTED} + ${M51328C14_TEST_STATISTICAL_ERROR})
    ${equation_SSH}=  Catenate  (${counter_SSH_value_after} - ${counter_SSH_value_before} > ${M51328C14_SHOULD_BE_COLLECTED} -
    ...  ${M51328C14_TEST_STATISTICAL_ERROR}) and (${counter_SSH_value_after} - ${counter_SSH_value_before} <
    ...  ${M51328C14_SHOULD_BE_COLLECTED} + ${M51328C14_TEST_STATISTICAL_ERROR})
    Should Be True  ${counter_WebEm_value_after} == ${counter_NetAct_value_after} == (${counter_SSH_value_after} - ${counter_SSH_value_before})
    Should Be True  ${equation_WebEm}
    Should Be True  ${equation_NetAct}
    Should Be True  ${equation_SSH}
    log  packets were successfully collected in M51328C14 transport counter on BTS  console=yes

[1]CB007672-5G-A-Rate_Limit_for_5G_C-Plane_ipRmDropPcktsRtLim5GCplane_IPv6
    ${pps_number}=   Keywords.Get ASIB Or ASIL PPS Number For Certain Counter  11
    ${burst_number}=   Keywords.Get ASIB Or ASIL Burst Number For Certain Counter  11
    Should Be True  ${pps_number} == ${M51328C14_LIMIT}
    Should Be True  ${burst_number} == ${M51328C14_BURST} or ${burst_number} == ${M51328C14_BURST_SECOND_FOR_ASIL}
    log to console  pps number is correct: ${pps_number}
    log to console  burst number is correct: ${burst_number}
    Change Rejected Packets Interval and Reporting Interval parameters value to 5 minutes
    Run Keyword And Ignore Error  Check If There Are Any Transport Counter Issues And Reboot BTS If Neened  M51328C14
    Wait Until Transport Counters Available After Reboot  M51328C14
    Actualize NetAct Counters
    Wait For New Interval Start  M51328C14
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C14
    ${counter_WebEm_value_before}=  Get Counter Value From WebEm  M51328C14
    ${counter_NetAct_value_before}=  Get Counter Value From NetAct  M51328C14
    ${counter_SSH_value_before}=  Get Counter Value From BTS Via SSH For ASIL For Certain Counter  5GCplane RL Counter
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    log  NetAct and WebEm counters time is correct  console=yes
    Remove NetAct Counters Raport
    log  counter value from WebEm before test is ${counter_WebEm_value_before}  console=yes
    log  counter value from NetAct before test is ${counter_NetAct_value_before}  console=yes
    log  counter value from BTS before test is ${counter_SSH_value_before}  console=yes
    Start Tcpdump For M51328C14 Counter
    Send Packets For M51328C14 Counter To BTS IPv6
    Kill Tcpdump For M51328C14 Counter
    log  packets were successfully sent on BTS with tcpdump  console=yes
    ${number_of_packets}=  Get Number Of Packets After Packets Flood
    Should Be True  ${number_of_packets} > (${M51328C14_PACKETS} * ${M51328C14_TCPDUMP_STATISTICAL_ERROR_LESS})
    Should Be True  ${number_of_packets} < (${M51328C14_PACKETS} * ${M51328C14_TCPDUMP_STATISTICAL_ERROR_MORE})
    log  packets were successfully collected on BTS with tcpdump  console=yes
    Wait For New Interval Start  M51328C14
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C14
    ${counter_WebEm_value_after}=  Get Counter Value From WebEm  M51328C14
    ${counter_NetAct_value_after}=  Get Counter Value From NetAct  M51328C14
    ${counter_SSH_value_after}=  Get Counter Value From BTS Via SSH For ASIL For Certain Counter  5GCplane RL Counter
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    Remove NetAct Counters Raport
    log  counter value from WebEm after test is ${counter_WebEm_value_after}  console=yes
    log  counter value from NetAct after test is ${counter_NetAct_value_after}  console=yes
    log  counter value from BTS after test is ${counter_SSH_value_after}  console=yes
    ${equation_WebEm}=  Catenate  (${counter_WebEm_value_after} - ${counter_WebEm_value_before} > ${M51328C14_SHOULD_BE_COLLECTED} -
    ...  ${M51328C14_TEST_STATISTICAL_ERROR}) and (${counter_WebEm_value_after} - ${counter_WebEm_value_before} <
    ...  ${M51328C14_SHOULD_BE_COLLECTED} + ${M51328C14_TEST_STATISTICAL_ERROR})
    ${equation_NetAct}=  Catenate  (${counter_NetAct_value_after} - ${counter_NetAct_value_before} > ${M51328C14_SHOULD_BE_COLLECTED} -
    ...  ${M51328C14_TEST_STATISTICAL_ERROR}) and (${counter_NetAct_value_after} - ${counter_NetAct_value_before} <
    ...  ${M51328C14_SHOULD_BE_COLLECTED} + ${M51328C14_TEST_STATISTICAL_ERROR})
    ${equation_SSH}=  Catenate  (${counter_SSH_value_after} - ${counter_SSH_value_before} > ${M51328C14_SHOULD_BE_COLLECTED} -
    ...  ${M51328C14_TEST_STATISTICAL_ERROR}) and (${counter_SSH_value_after} - ${counter_SSH_value_before} <
    ...  ${M51328C14_SHOULD_BE_COLLECTED} + ${M51328C14_TEST_STATISTICAL_ERROR})
    Should Be True  ${counter_WebEm_value_after} == ${counter_NetAct_value_after} == (${counter_SSH_value_after} - ${counter_SSH_value_before})
    Should Be True  ${equation_WebEm}
    Should Be True  ${equation_NetAct}
    Should Be True  ${equation_SSH}
    log  packets were successfully collected in M51328C14 transport counter on BTS  console=yes

[1]CB007672-5G-A-Rate_Limit_for_ICMP_ipRmDropPcktsRtLimICMP
    ${pps_number}=   Keywords.Get ASIB Or ASIL PPS Number For Certain Counter  9
    ${burst_number}=   Keywords.Get ASIB Or ASIL Burst Number For Certain Counter  9
    Should Be True  ${pps_number} == ${M51328C15_LIMIT}
    Should Be True  ${burst_number} == ${M51328C15_BURST}
    log to console  pps number is correct: ${pps_number}
    log to console  burst number is correct: ${burst_number}
    Change Rejected Packets Interval and Reporting Interval parameters value to 5 minutes
    Run Keyword And Ignore Error  Check If There Are Any Transport Counter Issues And Reboot BTS If Neened  M51328C15
    Wait Until Transport Counters Available After Reboot  M51328C15
    Actualize NetAct Counters
    Wait For New Interval Start  M51328C15
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C15
    ${counter_WebEm_value_before}=  Get Counter Value From WebEm  M51328C15
    ${counter_NetAct_value_before}=  Get Counter Value From NetAct  M51328C15
    ${counter_SSH_value_before}=  Get Counter Value From BTS Via SSH For ASIL For Certain Counter  ICMP RL Counter
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    log  NetAct and WebEm counters time is correct  console=yes
    Remove NetAct Counters Raport
    log  counter value from WebEm before test is ${counter_WebEm_value_before}  console=yes
    log  counter value from NetAct before test is ${counter_NetAct_value_before}  console=yes
    log  counter value from BTS before test is ${counter_SSH_value_before}  console=yes
    Start Tcpdump For M51328C15 Counter
    Send Packets For M51328C15 Counter To BTS
    Kill Tcpdump For M51328C15 Counter
    log  packets were successfully sent on BTS with tcpdump  console=yes
    ${number_of_packets}=  Get Number Of Packets After Packets Flood
    Should Be True  ${number_of_packets} > (${M51328C15_PACKETS} * ${M51328C15_TCPDUMP_STATISTICAL_ERROR_LESS})
    Should Be True  ${number_of_packets} < (${M51328C15_PACKETS} * ${M51328C15_TCPDUMP_STATISTICAL_ERROR_MORE})
    log  packets were successfully collected on BTS with tcpdump  console=yes
    Wait For New Interval Start  M51328C15
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C15
    ${counter_WebEm_value_after}=  Get Counter Value From WebEm  M51328C15
    ${counter_NetAct_value_after}=  Get Counter Value From NetAct  M51328C15
    ${counter_SSH_value_after}=  Get Counter Value From BTS Via SSH For ASIL For Certain Counter  ICMP RL Counter
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    Remove NetAct Counters Raport
    log  counter value from WebEm after test is ${counter_WebEm_value_after}  console=yes
    log  counter value from NetAct after test is ${counter_NetAct_value_after}  console=yes
    log  counter value from BTS after test is ${counter_SSH_value_after}  console=yes
    ${equation_WebEm}=  Catenate  (${counter_WebEm_value_after} - ${counter_WebEm_value_before} > ${M51328C15_SHOULD_BE_COLLECTED} -
    ...  ${M51328C15_TEST_STATISTICAL_ERROR}) and (${counter_WebEm_value_after} - ${counter_WebEm_value_before} <
    ...  ${M51328C15_SHOULD_BE_COLLECTED} + ${M51328C15_TEST_STATISTICAL_ERROR})
    ${equation_NetAct}=  Catenate  (${counter_NetAct_value_after} - ${counter_NetAct_value_before} > ${M51328C15_SHOULD_BE_COLLECTED} -
    ...  ${M51328C15_TEST_STATISTICAL_ERROR}) and (${counter_NetAct_value_after} - ${counter_NetAct_value_before} <
    ...  ${M51328C15_SHOULD_BE_COLLECTED} + ${M51328C15_TEST_STATISTICAL_ERROR})
    ${equation_SSH}=  Catenate  (${counter_SSH_value_after} - ${counter_SSH_value_before} > ${M51328C15_SHOULD_BE_COLLECTED} -
    ...  ${M51328C15_TEST_STATISTICAL_ERROR}) and (${counter_SSH_value_after} - ${counter_SSH_value_before} <
    ...  ${M51328C15_SHOULD_BE_COLLECTED} + ${M51328C15_TEST_STATISTICAL_ERROR})
    Should Be True  ${counter_WebEm_value_after} == ${counter_NetAct_value_after} == (${counter_SSH_value_after} - ${counter_SSH_value_before})
    Should Be True  ${equation_WebEm}
    Should Be True  ${equation_NetAct}
    Should Be True  ${equation_SSH}
    log  packets were successfully collected in M51328C15 transport counter on BTS  console=yes

[1]CB007672-5G-A-Rate_Limit_for_ICMP_ipRmDropPcktsRtLimICMP_IPv6
    Set Test Variable    ${counter_id}    M51328C15
    ${IPv6_address}=    RUN  netstat -6 -rn | grep /120 | awk '/^::|:/ {print $1}' | cut -d'/' -f1
    ${IPv6_route}=     get_ipv6_route      ipv6_address=${IPv6_address}
    RUN     sudo ip -6 route add default via ${IPv6_route} dev eth0
    ${pps_number}=   Keywords.Get ASIB Or ASIL PPS Number For Certain Counter  9
    ${burst_number}=   Keywords.Get ASIB Or ASIL Burst Number For Certain Counter  9
    Should Be True  ${pps_number} == ${M51328C15_LIMIT}
    Should Be True  ${burst_number} == ${M51328C15_BURST}
    log to console  pps number is correct: ${pps_number}
    log to console  burst number is correct: ${burst_number}
    Change Rejected Packets Interval and Reporting Interval parameters value to 5 minutes
    Run Keyword And Ignore Error  Check If There Are Any Transport Counter Issues And Reboot BTS If Neened  M51328C15
    Wait Until Transport Counters Available After Reboot  M51328C15
    Actualize NetAct Counters
    Wait For New Interval Start  M51328C15
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C15
    ${counter_WebEm_value_before}=  Get Counter Value From WebEm  M51328C15
    ${counter_NetAct_value_before}=  Get Counter Value From NetAct  M51328C15
    ${counter_SSH_value_before}=  Get Counter Value From BTS Via SSH For ASIL For Certain Counter  ICMP RL Counter
    Compare NetAct And WebEm Counter Time
    log  NetAct and WebEm counters time is correct  console=yes
    Remove NetAct Counters Raport
    log  counter value from WebEm before test is ${counter_WebEm_value_before}  console=yes
    log  counter value from NetAct before test is ${counter_NetAct_value_before}  console=yes
    log  counter value from BTS before test is ${counter_SSH_value_before}  console=yes
    Start Tcpdump For M51328C15 Counter IPv6
    Send Packets For M51328C15 Counter To BTS IPv6
    Kill Tcpdump For M51328C15 Counter
    log  packets were successfully sent on BTS with tcpdump  console=yes
    ${number_of_packets}=  Get Number Of Packets After Packets Flood
    Should Be True  ${number_of_packets} > (${M51328C15_PACKETS} * ${M51328C15_TCPDUMP_STATISTICAL_ERROR_LESS})
    Should Be True  ${number_of_packets} < (${M51328C15_PACKETS} * ${M51328C15_TCPDUMP_STATISTICAL_ERROR_MORE})
    log  packets were successfully collected on BTS with tcpdump  console=yes
    Wait For New Interval Start  M51328C15
    Sleep     240s
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C15
    ${counter_WebEm_value_after}=  Get Counter Value From WebEm  M51328C15
    ${counter_NetAct_value_after}=  Get Counter Value From NetAct  M51328C15
    ${counter_SSH_value_after}=  Get Counter Value From BTS Via SSH For ASIL For Certain Counter  ICMP RL Counter
    Compare NetAct And WebEm Counter Time
    Remove NetAct Counters Raport
    log  counter value from WebEm after test is ${counter_WebEm_value_after}  console=yes
    log  counter value from NetAct after test is ${counter_NetAct_value_after}  console=yes
    log  counter value from BTS after test is ${counter_SSH_value_after}  console=yes
    ${equation_WebEm}=  Catenate  (${counter_WebEm_value_after} - ${counter_WebEm_value_before} > ${M51328C15_SHOULD_BE_COLLECTED} -
    ...  ${M51328C15_TEST_STATISTICAL_ERROR}) and (${counter_WebEm_value_after} - ${counter_WebEm_value_before} <
    ...  ${M51328C15_SHOULD_BE_COLLECTED} + ${M51328C15_TEST_STATISTICAL_ERROR})
    ${equation_NetAct}=  Catenate  (${counter_NetAct_value_after} - ${counter_NetAct_value_before} > ${M51328C15_SHOULD_BE_COLLECTED} -
    ...  ${M51328C15_TEST_STATISTICAL_ERROR}) and (${counter_NetAct_value_after} - ${counter_NetAct_value_before} <
    ...  ${M51328C15_SHOULD_BE_COLLECTED} + ${M51328C15_TEST_STATISTICAL_ERROR})
    ${equation_SSH}=  Catenate  (${counter_SSH_value_after} - ${counter_SSH_value_before} > ${M51328C15_SHOULD_BE_COLLECTED} -
    ...  ${M51328C15_TEST_STATISTICAL_ERROR}) and (${counter_SSH_value_after} - ${counter_SSH_value_before} <
    ...  ${M51328C15_SHOULD_BE_COLLECTED} + ${M51328C15_TEST_STATISTICAL_ERROR})
    Should Be True  ${counter_WebEm_value_after} == ${counter_NetAct_value_after} == (${counter_SSH_value_after} - ${counter_SSH_value_before})
    Should Be True  ${equation_WebEm}
    Should Be True  ${equation_NetAct}
    Should Be True  ${equation_SSH}
    log  packets were successfully collected in M51328C15 transport counter on BTS  console=yes

# <------------------------------------------ [2] ASIB + ABIO ------------------------------------------>
[2]CB007672-5G-A-Rate_Limit_for_UDP_echo_request_TWAMP_ipRmDropPcktsRtLimTwamp
    ${pps_number}=   Keywords.Get ASIB Or ASIL PPS Number For Certain Counter  5
    ${burst_number}=   Keywords.Get ASIB Or ASIL Burst Number For Certain Counter  5
    Should Be True  ${pps_number} == ${M51328C7_LIMIT}
    Should Be True  ${burst_number} == ${M51328C7_BURST}
    log to console  pps number is correct: ${pps_number}
    log to console  burst number is correct: ${burst_number}
    ${admin_conn}=  Connect to ADMIN
    Delete IPAPP Object From BTS      ${admin_conn}
    Create IPAPP Object if doesn't Exist or Change Parameter               ${admin_conn}
    Create TWAMPREFLECT Object        ${admin_conn}
    Disconnect from ADMIN             ${admin_conn}
    Change Rejected Packets Interval and Reporting Interval parameters value to 5 minutes
    Run Keyword And Ignore Error  Check If There Are Any Transport Counter Issues And Reboot BTS If Neened  M51328C7
    Wait Until Transport Counters Available After Reboot  M51328C7
    Actualize NetAct Counters
    Wait For New Interval Start  M51328C7
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C7
    ${counter_WebEm_value_before}=  Get Counter Value From WebEm  M51328C7
    ${counter_NetAct_value_before}=  Get Counter Value From NetAct  M51328C7
    ${counter_SSH_value_before}=  Get Counter Value From BTS Via SSH For ASIB For Certain Counter  5
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    log  NetAct and WebEm counters time is correct  console=yes
    Remove NetAct Counters Raport
    log  counter value from WebEm before test is ${counter_WebEm_value_before}  console=yes
    log  counter value from NetAct before test is ${counter_NetAct_value_before}  console=yes
    log  counter value from BTS before test is ${counter_SSH_value_before}  console=yes
    Start Tcpdump For M51328C18 Or M51328C12 Or M51328C7 Counters
    Send Packets For M51328C7 Counter To BTS
    Kill Tcpdump For M51328C18 Or M51328C12 Or M51328C7 Counters
    log  packets were successfully sent on BTS with tcpdump  console=yes
    ${number_of_packets}=  Get Number Of Packets After Packets Flood
#    we should divide number of collected packets by two because of TWAMP two-way specific
    ${equation_scapy_more}=  Catenate  (${number_of_packets} / 2) > (${M51328C7_PACKETS} *
    ...  ${M51328C7_NUMBER_OF_SCAPY_RUNS} * ${M51328C7_TCPDUMP_STATISTICAL_ERROR_LESS})
    ${equation_scapy_less}=  Catenate  (${number_of_packets} / 2) < (${M51328C7_PACKETS} *
    ...  ${M51328C7_NUMBER_OF_SCAPY_RUNS} * ${M51328C7_TCPDUMP_STATISTICAL_ERROR_MORE})
    Should Be True  ${equation_scapy_more}
    Should Be True  ${equation_scapy_less}
    log  packets were successfully collected on BTS with tcpdump  console=yes
    Wait For New Interval Start  M51328C7
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C7
    ${counter_WebEm_value_after}=  Get Counter Value From WebEm  M51328C7
    ${counter_NetAct_value_after}=  Get Counter Value From NetAct  M51328C7
    ${counter_SSH_value_after}=  Get Counter Value From BTS Via SSH For ASIB For Certain Counter  5
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    Remove NetAct Counters Raport
    log  counter value from WebEm after test is ${counter_WebEm_value_after}  console=yes
    log  counter value from NetAct after test is ${counter_NetAct_value_after}  console=yes
    log  counter value from BTS after test is ${counter_SSH_value_after}  console=yes
    ${equation_WebEm}=  Catenate  (${counter_WebEm_value_after} - ${counter_WebEm_value_before} > ${M51328C7_SHOULD_BE_COLLECTED} -
    ...  ${M51328C7_TEST_STATISTICAL_ERROR}) and (${counter_WebEm_value_after} - ${counter_WebEm_value_before} <
    ...  ${M51328C7_SHOULD_BE_COLLECTED} + ${M51328C7_TEST_STATISTICAL_ERROR})
    ${equation_NetAct}=  Catenate  (${counter_NetAct_value_after} - ${counter_NetAct_value_before} > ${M51328C7_SHOULD_BE_COLLECTED} -
    ...  ${M51328C7_TEST_STATISTICAL_ERROR}) and (${counter_NetAct_value_after} - ${counter_NetAct_value_before} <
    ...  ${M51328C7_SHOULD_BE_COLLECTED} + ${M51328C7_TEST_STATISTICAL_ERROR})
    ${equation_SSH}=  Catenate  (${counter_SSH_value_after} - ${counter_SSH_value_before} > ${M51328C7_SHOULD_BE_COLLECTED} -
    ...  ${M51328C7_TEST_STATISTICAL_ERROR}) and (${counter_SSH_value_after} - ${counter_SSH_value_before} <
    ...  ${M51328C7_SHOULD_BE_COLLECTED} + ${M51328C7_TEST_STATISTICAL_ERROR})
    Should Be True  ${counter_WebEm_value_after} == ${counter_NetAct_value_after} == (${counter_SSH_value_after} - ${counter_SSH_value_before})
    Should Be True  ${equation_WebEm}
    Should Be True  ${equation_NetAct}
    Should Be True  ${equation_SSH}
    log  packets were successfully collected in M51328C7 transport counter on BTS  console=yes
    ${admin_conn}=  Connect to ADMIN
    Delete IPAPP Object From BTS      ${admin_conn}
    Disconnect from ADMIN             ${admin_conn}

[2]CB007672-5G-A-Rate_Limit_for_TOP_ipRmDropPcktsRtLimSplane
    ${pps_number}=   Keywords.Get ASIB Or ASIL PPS Number For Certain Counter  4
    ${burst_number}=   Keywords.Get ASIB Or ASIL Burst Number For Certain Counter  4
    Should Be True  ${pps_number} == ${M51328C8_LIMIT}
    Should Be True  ${burst_number} == ${M51328C8_BURST}
    log to console  pps number is correct: ${pps_number}
    log to console  burst number is correct: ${burst_number}
    ${admin_conn}=  Connect to ADMIN
    ${original_S_Plane_IPNO_path}=  Get SPlaneIpAddressDN From BTS  ${admin_conn}
    ${original_master_IP_address}=  Get MasterIpAddress From BTS  ${admin_conn}
    ${S_Plane_IPNO_path}=  Get S_Plane IPv4 Address Path  ${admin_conn}
    ${source_ipv4_addr}=  Get Source IPv4 Address
    Change TOP MasterIpAddress On BTS  ${admin_conn}  ${source_ipv4_addr}
    Change SPlaneIpAddressDN On BTS  ${admin_conn}  ${S_Plane_IPNO_path}
    Disconnect from ADMIN       ${admin_conn}
    Change Rejected Packets Interval and Reporting Interval parameters value to 5 minutes
    Run Keyword And Ignore Error  Check If There Are Any Transport Counter Issues And Reboot BTS If Neened  M51328C8
    Wait Until Transport Counters Available After Reboot  M51328C8
    Actualize NetAct Counters
    Wait For New Interval Start  M51328C8
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C8
    ${counter_WebEm_value_before}=  Get Counter Value From WebEm  M51328C8
    ${counter_NetAct_value_before}=  Get Counter Value From NetAct  M51328C8
    ${counter_SSH_value_before}=  Get Counter Value From BTS Via SSH For ASIB For Certain Counter  4
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    log  NetAct and WebEm counters time is correct  console=yes
    Remove NetAct Counters Raport
    log  counter value from WebEm before test is ${counter_WebEm_value_before}  console=yes
    log  counter value from NetAct before test is ${counter_NetAct_value_before}  console=yes
    log  counter value from BTS before test is ${counter_SSH_value_before}  console=yes
    ${master_ip_addr}=  Get Source IPv4 Address
    Start Tcpdump For M51328C8 Counter  ${master_ip_addr}
    Send Packets For M51328C8 Counter To BTS  ${master_ip_addr}
    Kill Tcpdump For M51328C8 Counter  ${master_ip_addr}
    log  packets were successfully sent on BTS with tcpdump  console=yes
    ${number_of_packets}=  Get Number Of Packets After Packets Flood
    Should Be True  ${number_of_packets} > (${M51328C8_PACKETS} * ${M51328C8_TCPDUMP_STATISTICAL_ERROR_LESS})
    Should Be True  ${number_of_packets} < (${M51328C8_PACKETS} * ${M51328C8_TCPDUMP_STATISTICAL_ERROR_MORE})
    log  packets were successfully collected on BTS with tcpdump  console=yes
    Wait For New Interval Start  M51328C8
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C8
    ${counter_WebEm_value_after}=  Get Counter Value From WebEm  M51328C8
    ${counter_NetAct_value_after}=  Get Counter Value From NetAct  M51328C8
    ${counter_SSH_value_after}=  Get Counter Value From BTS Via SSH For ASIB For Certain Counter  4
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    Remove NetAct Counters Raport
    log  counter value from WebEm after test is ${counter_WebEm_value_after}  console=yes
    log  counter value from NetAct after test is ${counter_NetAct_value_after}  console=yes
    log  counter value from BTS after test is ${counter_SSH_value_after}  console=yes
    ${equation_WebEm}=  Catenate  (${counter_WebEm_value_after} - ${counter_WebEm_value_before} > ${M51328C8_SHOULD_BE_COLLECTED} -
    ...  ${M51328C8_TEST_STATISTICAL_ERROR}) and (${counter_WebEm_value_after} - ${counter_WebEm_value_before} <
    ...  ${M51328C8_SHOULD_BE_COLLECTED} + ${M51328C8_TEST_STATISTICAL_ERROR})
    ${equation_NetAct}=  Catenate  (${counter_NetAct_value_after} - ${counter_NetAct_value_before} > ${M51328C8_SHOULD_BE_COLLECTED} -
    ...  ${M51328C8_TEST_STATISTICAL_ERROR}) and (${counter_NetAct_value_after} - ${counter_NetAct_value_before} <
    ...  ${M51328C8_SHOULD_BE_COLLECTED} + ${M51328C8_TEST_STATISTICAL_ERROR})
    ${equation_SSH}=  Catenate  (${counter_SSH_value_after} - ${counter_SSH_value_before} > ${M51328C8_SHOULD_BE_COLLECTED} -
    ...  ${M51328C8_TEST_STATISTICAL_ERROR}) and (${counter_SSH_value_after} - ${counter_SSH_value_before} <
    ...  ${M51328C8_SHOULD_BE_COLLECTED} + ${M51328C8_TEST_STATISTICAL_ERROR})
    Should Be True  ${counter_WebEm_value_after} == ${counter_NetAct_value_after} == (${counter_SSH_value_after} - ${counter_SSH_value_before})
    Should Be True  ${equation_WebEm}
    Should Be True  ${equation_NetAct}
    Should Be True  ${equation_SSH}
    log  packets were successfully collected in M51328C8 transport counter on BTS  console=yes
    ${admin_conn}=  Connect to ADMIN
    Change TOP MasterIpAddress On BTS  ${admin_conn}  ${original_master_IP_address}
    Change SPlaneIpAddressDN On BTS  ${admin_conn}  ${original_S_Plane_IPNO_path}
    Disconnect from ADMIN       ${admin_conn}

[2]CB007672-5G-A-Rate_Limit_for_TOP_ipRmDropPcktsRtLimSplane_IPv6
    ${pps_number}=   Keywords.Get ASIB Or ASIL PPS Number For Certain Counter  4
    ${burst_number}=   Keywords.Get ASIB Or ASIL Burst Number For Certain Counter  4
    Should Be True  ${pps_number} == ${M51328C8_LIMIT}
    Should Be True  ${burst_number} == ${M51328C8_BURST}
    log to console  pps number is correct: ${pps_number}
    log to console  burst number is correct: ${burst_number}
    ${admin_conn}=  Connect to ADMIN
    ${original_S_Plane_IPNO_path}=  Get SPlaneIpAddressDN From BTS  ${admin_conn}
    ${original_master_IP_address}=  Get MasterIpAddress From BTS  ${admin_conn}
    ${S_Plane_IPNO_path}=  Get S_Plane IPv6 Address Path  ${admin_conn}
    ${source_ipv6_addr}=  Get Source IPv6 Address
    Change TOP MasterIpAddress On BTS  ${admin_conn}  ${source_ipv6_addr}
    Change SPlaneIpAddressDN On BTS  ${admin_conn}  ${S_Plane_IPNO_path}
    Disconnect from ADMIN       ${admin_conn}
    Change Rejected Packets Interval and Reporting Interval parameters value to 5 minutes
    Run Keyword And Ignore Error  Check If There Are Any Transport Counter Issues And Reboot BTS If Neened  M51328C8
    Wait Until Transport Counters Available After Reboot  M51328C8
    Actualize NetAct Counters
    Wait For New Interval Start  M51328C8
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C8
    ${counter_WebEm_value_before}=  Get Counter Value From WebEm  M51328C8
    ${counter_NetAct_value_before}=  Get Counter Value From NetAct  M51328C8
    ${counter_SSH_value_before}=  Get Counter Value From BTS Via SSH For ASIB For Certain Counter  4
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    log  NetAct and WebEm counters time is correct  console=yes
    Remove NetAct Counters Raport
    log  counter value from WebEm before test is ${counter_WebEm_value_before}  console=yes
    log  counter value from NetAct before test is ${counter_NetAct_value_before}  console=yes
    log  counter value from BTS before test is ${counter_SSH_value_before}  console=yes
    ${master_ip_addr}=  Get Source IPv6 Address
    Start Tcpdump For M51328C8 Counter  ${master_ip_addr}
    Send Packets For M51328C8 Counter To BTS IPv6  ${master_ip_addr}
    Kill Tcpdump For M51328C8 Counter  ${master_ip_addr}
    log  packets were successfully sent on BTS with tcpdump  console=yes
    ${number_of_packets}=  Get Number Of Packets After Packets Flood
    Should Be True  ${number_of_packets} > (${M51328C8_PACKETS} * ${M51328C8_TCPDUMP_STATISTICAL_ERROR_LESS})
    Should Be True  ${number_of_packets} < (${M51328C8_PACKETS} * ${M51328C8_TCPDUMP_STATISTICAL_ERROR_MORE})
    log  packets were successfully collected on BTS with tcpdump  console=yes
    Wait For New Interval Start  M51328C8
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C8
    ${counter_WebEm_value_after}=  Get Counter Value From WebEm  M51328C8
    ${counter_NetAct_value_after}=  Get Counter Value From NetAct  M51328C8
    ${counter_SSH_value_after}=  Get Counter Value From BTS Via SSH For ASIB For Certain Counter  4
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    Remove NetAct Counters Raport
    log  counter value from WebEm after test is ${counter_WebEm_value_after}  console=yes
    log  counter value from NetAct after test is ${counter_NetAct_value_after}  console=yes
    log  counter value from BTS after test is ${counter_SSH_value_after}  console=yes
    ${equation_WebEm}=  Catenate  (${counter_WebEm_value_after} - ${counter_WebEm_value_before} > ${M51328C8_SHOULD_BE_COLLECTED} -
    ...  ${M51328C8_TEST_STATISTICAL_ERROR}) and (${counter_WebEm_value_after} - ${counter_WebEm_value_before} <
    ...  ${M51328C8_SHOULD_BE_COLLECTED} + ${M51328C8_TEST_STATISTICAL_ERROR})
    ${equation_NetAct}=  Catenate  (${counter_NetAct_value_after} - ${counter_NetAct_value_before} > ${M51328C8_SHOULD_BE_COLLECTED} -
    ...  ${M51328C8_TEST_STATISTICAL_ERROR}) and (${counter_NetAct_value_after} - ${counter_NetAct_value_before} <
    ...  ${M51328C8_SHOULD_BE_COLLECTED} + ${M51328C8_TEST_STATISTICAL_ERROR})
    ${equation_SSH}=  Catenate  (${counter_SSH_value_after} - ${counter_SSH_value_before} > ${M51328C8_SHOULD_BE_COLLECTED} -
    ...  ${M51328C8_TEST_STATISTICAL_ERROR}) and (${counter_SSH_value_after} - ${counter_SSH_value_before} <
    ...  ${M51328C8_SHOULD_BE_COLLECTED} + ${M51328C8_TEST_STATISTICAL_ERROR})
    Should Be True  ${counter_WebEm_value_after} == ${counter_NetAct_value_after} == (${counter_SSH_value_after} - ${counter_SSH_value_before})
    Should Be True  ${equation_WebEm}
    Should Be True  ${equation_NetAct}
    Should Be True  ${equation_SSH}
    log  packets were successfully collected in M51328C8 transport counter on BTS  console=yes
    ${admin_conn}=  Connect to ADMIN
    Change TOP MasterIpAddress On BTS  ${admin_conn}  ${original_master_IP_address}
    Change SPlaneIpAddressDN On BTS  ${admin_conn}  ${original_S_Plane_IPNO_path}
    Disconnect from ADMIN       ${admin_conn}

[2]CB007672-5G-A-Rate_Limit_for_M-plane_LTE_ipRmDropPcktsRtLimSrLteMplane
    ${counter_id_status}=  Run Keyword And Ignore Error  Get Counter Value From WebEm  M51328C18
    ${counter_id}=  Set Variable If  'PASS' in ${counter_id_status}  M51328C18  M51328C11
    Set Test Variable    ${counter_id}
    ${pps_number}=   Keywords.Get ASIB Or ASIL PPS Number For Certain Counter  6
    ${burst_number}=   Keywords.Get ASIB Or ASIL Burst Number For Certain Counter  6
    Should Be True  ${pps_number} == ${M51328C18_LIMIT}
    Should Be True  ${burst_number} == ${M51328C18_BURST}
    log to console  pps number is correct: ${pps_number}
    log to console  burst number is correct: ${burst_number}
    Change Rejected Packets Interval and Reporting Interval parameters value to 5 minutes
    Run Keyword And Ignore Error  Check If There Are Any Transport Counter Issues And Reboot BTS If Neened  ${counter_id}
    Wait Until Transport Counters Available After Reboot  ${counter_id}
    Actualize NetAct Counters
    Wait For New Interval Start  ${counter_id}
    ${WebEm_counter_time}=  Get Counter Time From WebEm  ${counter_id}
    ${counter_WebEm_value_before}=  Get Counter Value From WebEm  ${counter_id}
    ${counter_NetAct_value_before}=  Get Counter Value From NetAct  ${counter_id}
    ${counter_SSH_value_before}=  Get Counter Value From BTS Via SSH For ASIB For Certain Counter  6
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    log  NetAct and WebEm counters time is correct  console=yes
    Remove NetAct Counters Raport
    log  counter value from WebEm before test is ${counter_WebEm_value_before}  console=yes
    log  counter value from NetAct before test is ${counter_NetAct_value_before}  console=yes
    log  counter value from BTS before test is ${counter_SSH_value_before}  console=yes
    Start Tcpdump For M51328C18 Or M51328C12 Or M51328C7 Counters
    Send Packets For M51328C18 Counter To BTS
    Kill Tcpdump For M51328C18 Or M51328C12 Or M51328C7 Counters
    log  packets were successfully sent on BTS with tcpdump  console=yes
    ${number_of_packets}=  Get Number Of Packets After Packets Flood
    Should Be True  ${number_of_packets} > (${M51328C18_PACKETS} * ${M51328C18_TCPDUMP_STATISTICAL_ERROR_LESS})
    Should Be True  ${number_of_packets} < (${M51328C18_PACKETS} * ${M51328C18_TCPDUMP_STATISTICAL_ERROR_MORE})
    log  packets were successfully collected on BTS with tcpdump  console=yes
    Wait For New Interval Start  ${counter_id}
    ${WebEm_counter_time}=  Get Counter Time From WebEm  ${counter_id}
    ${counter_WebEm_value_after}=  Get Counter Value From WebEm  ${counter_id}
    ${counter_NetAct_value_after}=  Get Counter Value From NetAct  ${counter_id}
    ${counter_SSH_value_after}=  Get Counter Value From BTS Via SSH For ASIB For Certain Counter  6
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    Remove NetAct Counters Raport
    log  counter value from WebEm after test is ${counter_WebEm_value_after}  console=yes
    log  counter value from NetAct after test is ${counter_NetAct_value_after}  console=yes
    log  counter value from BTS after test is ${counter_SSH_value_after}  console=yes
    ${equation_WebEm}=  Catenate  (${counter_WebEm_value_after} - ${counter_WebEm_value_before} > ${M51328C18_SHOULD_BE_COLLECTED} -
    ...  ${M51328C18_TEST_STATISTICAL_ERROR}) and (${counter_WebEm_value_after} - ${counter_WebEm_value_before} <
    ...  ${M51328C18_SHOULD_BE_COLLECTED} + ${M51328C18_TEST_STATISTICAL_ERROR})
    ${equation_NetAct}=  Catenate  (${counter_NetAct_value_after} - ${counter_NetAct_value_before} > ${M51328C18_SHOULD_BE_COLLECTED} -
    ...  ${M51328C18_TEST_STATISTICAL_ERROR}) and (${counter_NetAct_value_after} - ${counter_NetAct_value_before} <
    ...  ${M51328C18_SHOULD_BE_COLLECTED} + ${M51328C18_TEST_STATISTICAL_ERROR})
    ${equation_SSH}=  Catenate  (${counter_SSH_value_after} - ${counter_SSH_value_before} > ${M51328C18_SHOULD_BE_COLLECTED} -
    ...  ${M51328C18_TEST_STATISTICAL_ERROR}) and (${counter_SSH_value_after} - ${counter_SSH_value_before} <
    ...  ${M51328C18_SHOULD_BE_COLLECTED} + ${M51328C18_TEST_STATISTICAL_ERROR})
    Should Be True  ${counter_WebEm_value_after} == ${counter_NetAct_value_after} == (${counter_SSH_value_after} - ${counter_SSH_value_before})
    Should Be True  ${equation_WebEm}
    Should Be True  ${equation_NetAct}
    Should Be True  ${equation_SSH}
    log  packets were successfully collected in ${counter_id} transport counter on BTS  console=yes

[2]CB007672-5G-A-Rate_Limit_for_Other_Non-M-plane_IP_ipRmDropPcktsRtLimDefault
    ${pps_number}=   Keywords.Get ASIB Or ASIL PPS Number For Certain Counter  18
    ${burst_number}=   Keywords.Get ASIB Or ASIL Burst Number For Certain Counter  18
    Should Be True  ${pps_number} == ${M51328C12_LIMIT}
    Should Be True  ${burst_number} == ${M51328C12_BURST}
    log to console  pps number is correct: ${pps_number}
    log to console  burst number is correct: ${burst_number}
    Change Rejected Packets Interval and Reporting Interval parameters value to 5 minutes
    Run Keyword And Ignore Error  Check If There Are Any Transport Counter Issues And Reboot BTS If Neened  M51328C12
    Wait Until Transport Counters Available After Reboot  M51328C12
    Actualize NetAct Counters
    Wait For New Interval Start  M51328C12
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C12
    ${counter_WebEm_value_before}=  Get Counter Value From WebEm  M51328C12
    ${counter_NetAct_value_before}=  Get Counter Value From NetAct  M51328C12
    ${counter_SSH_value_before}=  Get Counter Value From BTS Via SSH For ASIB For Certain Counter  18
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    log  NetAct and WebEm counters time is correct  console=yes
    Remove NetAct Counters Raport
    log  counter value from WebEm before test is ${counter_WebEm_value_before}  console=yes
    log  counter value from NetAct before test is ${counter_NetAct_value_before}  console=yes
    log  counter value from BTS before test is ${counter_SSH_value_before}  console=yes
    Start Tcpdump For M51328C18 Or M51328C12 Or M51328C7 Counters
    Send Packets For M51328C12 Counter To BTS
    Kill Tcpdump For M51328C18 Or M51328C12 Or M51328C7 Counters
    log  packets were successfully sent on BTS with tcpdump  console=yes
    ${number_of_packets}=  Get Number Of Packets After Packets Flood
    Should Be True  ${number_of_packets} > (${M51328C12_PACKETS} * ${M51328C12_TCPDUMP_STATISTICAL_ERROR_LESS})
    Should Be True  ${number_of_packets} < (${M51328C12_PACKETS} * ${M51328C12_TCPDUMP_STATISTICAL_ERROR_MORE})
    log  packets were successfully collected on BTS with tcpdump  console=yes
    Wait For New Interval Start  M51328C12
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C12
    ${counter_WebEm_value_after}=  Get Counter Value From WebEm  M51328C12
    ${counter_NetAct_value_after}=  Get Counter Value From NetAct  M51328C12
    ${counter_SSH_value_after}=  Get Counter Value From BTS Via SSH For ASIB For Certain Counter  18
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    Remove NetAct Counters Raport
    log  counter value from WebEm after test is ${counter_WebEm_value_after}  console=yes
    log  counter value from NetAct after test is ${counter_NetAct_value_after}  console=yes
    log  counter value from BTS after test is ${counter_SSH_value_after}  console=yes
    ${equation_WebEm}=  Catenate  (${counter_WebEm_value_after} - ${counter_WebEm_value_before} > ${M51328C12_SHOULD_BE_COLLECTED} -
    ...  ${M51328C12_TEST_STATISTICAL_ERROR}) and (${counter_WebEm_value_after} - ${counter_WebEm_value_before} <
    ...  ${M51328C12_SHOULD_BE_COLLECTED} + ${M51328C12_TEST_STATISTICAL_ERROR})
    ${equation_NetAct}=  Catenate  (${counter_NetAct_value_after} - ${counter_NetAct_value_before} > ${M51328C12_SHOULD_BE_COLLECTED} -
    ...  ${M51328C12_TEST_STATISTICAL_ERROR}) and (${counter_NetAct_value_after} - ${counter_NetAct_value_before} <
    ...  ${M51328C12_SHOULD_BE_COLLECTED} + ${M51328C12_TEST_STATISTICAL_ERROR})
    ${equation_SSH}=  Catenate  (${counter_SSH_value_after} - ${counter_SSH_value_before} > ${M51328C12_SHOULD_BE_COLLECTED} -
    ...  ${M51328C12_TEST_STATISTICAL_ERROR}) and (${counter_SSH_value_after} - ${counter_SSH_value_before} <
    ...  ${M51328C12_SHOULD_BE_COLLECTED} + ${M51328C12_TEST_STATISTICAL_ERROR})
    Should Be True  ${counter_WebEm_value_after} == ${counter_NetAct_value_after} == (${counter_SSH_value_after} - ${counter_SSH_value_before})
    Should Be True  ${equation_WebEm}
    Should Be True  ${equation_NetAct}
    Should Be True  ${equation_SSH}
    log  packets were successfully collected in M51328C12 transport counter on BTS  console=yes

[2]CB007672-5G-A-Rate_Limit_for_5G_C-Plane_ipRmDropPcktsRtLim5GCplane
    ${pps_number}=   Keywords.Get ASIB Or ASIL PPS Number For Certain Counter  11
    ${burst_number}=   Keywords.Get ASIB Or ASIL Burst Number For Certain Counter  11
    Should Be True  ${pps_number} == ${M51328C14_LIMIT}
    Should Be True  ${burst_number} == ${M51328C14_BURST}
    log to console  pps number is correct: ${pps_number}
    log to console  burst number is correct: ${burst_number}
    Change Rejected Packets Interval and Reporting Interval parameters value to 5 minutes
    Run Keyword And Ignore Error  Check If There Are Any Transport Counter Issues And Reboot BTS If Neened  M51328C14
    Wait Until Transport Counters Available After Reboot  M51328C14
    Actualize NetAct Counters
    Wait For New Interval Start  M51328C14
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C14
    ${counter_WebEm_value_before}=  Get Counter Value From WebEm  M51328C14
    ${counter_NetAct_value_before}=  Get Counter Value From NetAct  M51328C14
    ${counter_SSH_value_before}=  Get Counter Value From BTS Via SSH For ASIB For Certain Counter  11
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    log  NetAct and WebEm counters time is correct  console=yes
    Remove NetAct Counters Raport
    log  counter value from WebEm before test is ${counter_WebEm_value_before}  console=yes
    log  counter value from NetAct before test is ${counter_NetAct_value_before}  console=yes
    log  counter value from BTS before test is ${counter_SSH_value_before}  console=yes
    Start Tcpdump For M51328C14 Counter
    Send Packets For M51328C14 Counter To BTS
    Kill Tcpdump For M51328C14 Counter
    log  packets were successfully sent on BTS with tcpdump  console=yes
    ${number_of_packets}=  Get Number Of Packets After Packets Flood
    Should Be True  ${number_of_packets} > (${M51328C14_PACKETS} * ${M51328C14_TCPDUMP_STATISTICAL_ERROR_LESS})
    Should Be True  ${number_of_packets} < (${M51328C14_PACKETS} * ${M51328C14_TCPDUMP_STATISTICAL_ERROR_MORE})
    log  packets were successfully collected on BTS with tcpdump  console=yes
    Wait For New Interval Start  M51328C14
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C14
    ${counter_WebEm_value_after}=  Get Counter Value From WebEm  M51328C14
    ${counter_NetAct_value_after}=  Get Counter Value From NetAct  M51328C14
    ${counter_SSH_value_after}=  Get Counter Value From BTS Via SSH For ASIB For Certain Counter  11
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    Remove NetAct Counters Raport
    log  counter value from WebEm after test is ${counter_WebEm_value_after}  console=yes
    log  counter value from NetAct after test is ${counter_NetAct_value_after}  console=yes
    log  counter value from BTS after test is ${counter_SSH_value_after}  console=yes
    ${equation_WebEm}=  Catenate  (${counter_WebEm_value_after} - ${counter_WebEm_value_before} > ${M51328C14_SHOULD_BE_COLLECTED} -
    ...  ${M51328C14_TEST_STATISTICAL_ERROR}) and (${counter_WebEm_value_after} - ${counter_WebEm_value_before} <
    ...  ${M51328C14_SHOULD_BE_COLLECTED} + ${M51328C14_TEST_STATISTICAL_ERROR})
    ${equation_NetAct}=  Catenate  (${counter_NetAct_value_after} - ${counter_NetAct_value_before} > ${M51328C14_SHOULD_BE_COLLECTED} -
    ...  ${M51328C14_TEST_STATISTICAL_ERROR}) and (${counter_NetAct_value_after} - ${counter_NetAct_value_before} <
    ...  ${M51328C14_SHOULD_BE_COLLECTED} + ${M51328C14_TEST_STATISTICAL_ERROR})
    ${equation_SSH}=  Catenate  (${counter_SSH_value_after} - ${counter_SSH_value_before} > ${M51328C14_SHOULD_BE_COLLECTED} -
    ...  ${M51328C14_TEST_STATISTICAL_ERROR}) and (${counter_SSH_value_after} - ${counter_SSH_value_before} <
    ...  ${M51328C14_SHOULD_BE_COLLECTED} + ${M51328C14_TEST_STATISTICAL_ERROR})
    Should Be True  ${counter_WebEm_value_after} == ${counter_NetAct_value_after} == (${counter_SSH_value_after} - ${counter_SSH_value_before})
    Should Be True  ${equation_WebEm}
    Should Be True  ${equation_NetAct}
    Should Be True  ${equation_SSH}
    log  packets were successfully collected in M51328C14 transport counter on BTS  console=yes

[2]CB007672-5G-A-Rate_Limit_for_ICMP_ipRmDropPcktsRtLimICMP
    ${pps_number}=   Keywords.Get ASIB Or ASIL PPS Number For Certain Counter  9
    ${burst_number}=   Keywords.Get ASIB Or ASIL Burst Number For Certain Counter  9
    Should Be True  ${pps_number} == ${M51328C15_LIMIT}
    Should Be True  ${burst_number} == ${M51328C15_BURST}
    log to console  pps number is correct: ${pps_number}
    log to console  burst number is correct: ${burst_number}
    Change Rejected Packets Interval and Reporting Interval parameters value to 5 minutes
    Run Keyword And Ignore Error  Check If There Are Any Transport Counter Issues And Reboot BTS If Neened  M51328C15
    Wait Until Transport Counters Available After Reboot  M51328C15
    Actualize NetAct Counters
    Wait For New Interval Start  M51328C15
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C15
    ${counter_WebEm_value_before}=  Get Counter Value From WebEm  M51328C15
    ${counter_NetAct_value_before}=  Get Counter Value From NetAct  M51328C15
    ${counter_SSH_value_before}=  Get Counter Value From BTS Via SSH For ASIB For Certain Counter  9
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    log  NetAct and WebEm counters time is correct  console=yes
    Remove NetAct Counters Raport
    log  counter value from WebEm before test is ${counter_WebEm_value_before}  console=yes
    log  counter value from NetAct before test is ${counter_NetAct_value_before}  console=yes
    log  counter value from BTS before test is ${counter_SSH_value_before}  console=yes
    Start Tcpdump For M51328C15 Counter
    Send Packets For M51328C15 Counter To BTS
    Kill Tcpdump For M51328C15 Counter
    log  packets were successfully sent on BTS with tcpdump  console=yes
    ${number_of_packets}=  Get Number Of Packets After Packets Flood
    Should Be True  ${number_of_packets} > (${M51328C15_PACKETS} * ${M51328C15_TCPDUMP_STATISTICAL_ERROR_LESS})
    Should Be True  ${number_of_packets} < (${M51328C15_PACKETS} * ${M51328C15_TCPDUMP_STATISTICAL_ERROR_MORE})
    log  packets were successfully collected on BTS with tcpdump  console=yes
    Wait For New Interval Start  M51328C15
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C15
    ${counter_WebEm_value_after}=  Get Counter Value From WebEm  M51328C15
    ${counter_NetAct_value_after}=  Get Counter Value From NetAct  M51328C15
    ${counter_SSH_value_after}=  Get Counter Value From BTS Via SSH For ASIB For Certain Counter  9
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    Remove NetAct Counters Raport
    log  counter value from WebEm after test is ${counter_WebEm_value_after}  console=yes
    log  counter value from NetAct after test is ${counter_NetAct_value_after}  console=yes
    log  counter value from BTS after test is ${counter_SSH_value_after}  console=yes
    ${equation_WebEm}=  Catenate  (${counter_WebEm_value_after} - ${counter_WebEm_value_before} > ${M51328C15_SHOULD_BE_COLLECTED} -
    ...  ${M51328C15_TEST_STATISTICAL_ERROR}) and (${counter_WebEm_value_after} - ${counter_WebEm_value_before} <
    ...  ${M51328C15_SHOULD_BE_COLLECTED} + ${M51328C15_TEST_STATISTICAL_ERROR})
    ${equation_NetAct}=  Catenate  (${counter_NetAct_value_after} - ${counter_NetAct_value_before} > ${M51328C15_SHOULD_BE_COLLECTED} -
    ...  ${M51328C15_TEST_STATISTICAL_ERROR}) and (${counter_NetAct_value_after} - ${counter_NetAct_value_before} <
    ...  ${M51328C15_SHOULD_BE_COLLECTED} + ${M51328C15_TEST_STATISTICAL_ERROR})
    ${equation_SSH}=  Catenate  (${counter_SSH_value_after} - ${counter_SSH_value_before} > ${M51328C15_SHOULD_BE_COLLECTED} -
    ...  ${M51328C15_TEST_STATISTICAL_ERROR}) and (${counter_SSH_value_after} - ${counter_SSH_value_before} <
    ...  ${M51328C15_SHOULD_BE_COLLECTED} + ${M51328C15_TEST_STATISTICAL_ERROR})
    Should Be True  ${counter_WebEm_value_after} == ${counter_NetAct_value_after} == (${counter_SSH_value_after} - ${counter_SSH_value_before})
    Should Be True  ${equation_WebEm}
    Should Be True  ${equation_NetAct}
    Should Be True  ${equation_SSH}
    log  packets were successfully collected in M51328C15 transport counter on BTS  console=yes

# <------------------------------------------ [3] ASIK + ABIL (also ASIM) ------------------------------------------>
[3]CB007672-5G-A-Rate_Limit_for_UDP_echo_request_TWAMP_ipRmDropPcktsRtLimTwamp
    ${admin_conn}=  Connect to ADMIN
    Delete IPAPP Object From BTS      ${admin_conn}
    Create IPAPP Object if doesn't Exist or Change Parameter               ${admin_conn}
    Create TWAMPREFLECT Object        ${admin_conn}
    Disconnect from ADMIN             ${admin_conn}
    Change Rejected Packets Interval and Reporting Interval parameters value to 5 minutes
    Run Keyword And Ignore Error  Check If There Are Any Transport Counter Issues And Reboot BTS If Neened  M51328C7
    Wait Until Transport Counters Available After Reboot  M51328C7
    Actualize NetAct Counters
    Wait For New Interval Start  M51328C7
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C7
    ${counter_WebEm_value_before}=  Get Counter Value From WebEm  M51328C7
    ${counter_NetAct_value_before}=  Get Counter Value From NetAct  M51328C7
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    log  NetAct and WebEm counters time is correct  console=yes
    Remove NetAct Counters Raport
    log  counter value from WebEm before test is ${counter_WebEm_value_before}  console=yes
    log  counter value from NetAct before test is ${counter_NetAct_value_before}  console=yes
    Start Tcpdump For M51328C18 Or M51328C12 Or M51328C7 Counters
    Send Packets For M51328C7 Counter To BTS
    Kill Tcpdump For M51328C18 Or M51328C12 Or M51328C7 Counters
    log  packets were successfully sent on BTS with tcpdump  console=yes
    ${number_of_packets}=  Get Number Of Packets After Packets Flood
#    we should divide number of collected packets by two because of TWAMP two-way specific
    ${equation_scapy_more}=  Catenate  (${number_of_packets} / 2) > (${M51328C7_PACKETS} *
    ...  ${M51328C7_NUMBER_OF_SCAPY_RUNS} * ${M51328C7_TCPDUMP_STATISTICAL_ERROR_LESS})
    ${equation_scapy_less}=  Catenate  (${number_of_packets} / 2) < (${M51328C7_PACKETS} *
    ...  ${M51328C7_NUMBER_OF_SCAPY_RUNS} * ${M51328C7_TCPDUMP_STATISTICAL_ERROR_MORE})
    Should Be True  ${equation_scapy_more}
    Should Be True  ${equation_scapy_less}
    log  packets were successfully collected on BTS with tcpdump  console=yes
    Wait For New Interval Start  M51328C7
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C7
    ${counter_WebEm_value_after}=  Get Counter Value From WebEm  M51328C7
    ${counter_NetAct_value_after}=  Get Counter Value From NetAct  M51328C7
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    Remove NetAct Counters Raport
    log  counter value from WebEm after test is ${counter_WebEm_value_after}  console=yes
    log  counter value from NetAct after test is ${counter_NetAct_value_after}  console=yes
    ${equation_WebEm}=  Catenate  (${counter_WebEm_value_after} - ${counter_WebEm_value_before} > ${M51328C7_SHOULD_BE_COLLECTED} -
    ...  ${M51328C7_TEST_STATISTICAL_ERROR}) and (${counter_WebEm_value_after} - ${counter_WebEm_value_before} <
    ...  ${M51328C7_SHOULD_BE_COLLECTED} + ${M51328C7_TEST_STATISTICAL_ERROR})
    ${equation_NetAct}=  Catenate  (${counter_NetAct_value_after} - ${counter_NetAct_value_before} > ${M51328C7_SHOULD_BE_COLLECTED} -
    ...  ${M51328C7_TEST_STATISTICAL_ERROR}) and (${counter_NetAct_value_after} - ${counter_NetAct_value_before} <
    ...  ${M51328C7_SHOULD_BE_COLLECTED} + ${M51328C7_TEST_STATISTICAL_ERROR})
    Should Be True  ${counter_WebEm_value_after} == ${counter_NetAct_value_after}
    Should Be True  ${equation_WebEm}
    Should Be True  ${equation_NetAct}
    log  packets were successfully collected in M51328C7 transport counter on BTS  console=yes
    ${admin_conn}=  Connect to ADMIN
    Delete IPAPP Object From BTS      ${admin_conn}
    Disconnect from ADMIN             ${admin_conn}

[3]CB007672-5G-A-Rate_Limit_for_UDP_echo_request_TWAMP_ipRmDropPcktsRtLimTwamp_IPv6
    ${admin_conn}=  Connect to ADMIN
    Delete IPAPP Object From BTS      ${admin_conn}
    Create IPAPP Object if doesn't Exist or Change Parameter               ${admin_conn}
    Create TWAMPREFLECT Object        ${admin_conn}
    Disconnect from ADMIN             ${admin_conn}
    Change Rejected Packets Interval and Reporting Interval parameters value to 5 minutes
    Run Keyword And Ignore Error  Check If There Are Any Transport Counter Issues And Reboot BTS If Neened  M51328C7
    Wait Until Transport Counters Available After Reboot  M51328C7
    Actualize NetAct Counters
    Wait For New Interval Start  M51328C7
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C7
    ${counter_WebEm_value_before}=  Get Counter Value From WebEm  M51328C7
    ${counter_NetAct_value_before}=  Get Counter Value From NetAct  M51328C7
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    log  NetAct and WebEm counters time is correct  console=yes
    Remove NetAct Counters Raport
    log  counter value from WebEm before test is ${counter_WebEm_value_before}  console=yes
    log  counter value from NetAct before test is ${counter_NetAct_value_before}  console=yes
    Start Tcpdump For M51328C18 Or M51328C12 Or M51328C7 Counters
    Send Packets For M51328C7 Counter To BTS IPv6
    Kill Tcpdump For M51328C18 Or M51328C12 Or M51328C7 Counters
    log  packets were successfully sent on BTS with tcpdump  console=yes
    ${number_of_packets}=  Get Number Of Packets After Packets Flood
#    we should divide number of collected packets by two because of TWAMP two-way specific
    ${equation_scapy_more}=  Catenate  (${number_of_packets} / 2) > (${M51328C7_PACKETS} *
    ...  ${M51328C7_NUMBER_OF_SCAPY_RUNS} * ${M51328C7_TCPDUMP_STATISTICAL_ERROR_LESS})
    ${equation_scapy_less}=  Catenate  (${number_of_packets} / 2) < (${M51328C7_PACKETS} *
    ...  ${M51328C7_NUMBER_OF_SCAPY_RUNS} * ${M51328C7_TCPDUMP_STATISTICAL_ERROR_MORE})
    Should Be True  ${equation_scapy_more}
    Should Be True  ${equation_scapy_less}
    log  packets were successfully collected on BTS with tcpdump  console=yes
    Wait For New Interval Start  M51328C7
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C7
    ${counter_WebEm_value_after}=  Get Counter Value From WebEm  M51328C7
    ${counter_NetAct_value_after}=  Get Counter Value From NetAct  M51328C7
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    Remove NetAct Counters Raport
    log  counter value from WebEm after test is ${counter_WebEm_value_after}  console=yes
    log  counter value from NetAct after test is ${counter_NetAct_value_after}  console=yes
    ${equation_WebEm}=  Catenate  (${counter_WebEm_value_after} - ${counter_WebEm_value_before} > ${M51328C7_SHOULD_BE_COLLECTED} -
    ...  ${M51328C7_TEST_STATISTICAL_ERROR}) and (${counter_WebEm_value_after} - ${counter_WebEm_value_before} <
    ...  ${M51328C7_SHOULD_BE_COLLECTED} + ${M51328C7_TEST_STATISTICAL_ERROR})
    ${equation_NetAct}=  Catenate  (${counter_NetAct_value_after} - ${counter_NetAct_value_before} > ${M51328C7_SHOULD_BE_COLLECTED} -
    ...  ${M51328C7_TEST_STATISTICAL_ERROR}) and (${counter_NetAct_value_after} - ${counter_NetAct_value_before} <
    ...  ${M51328C7_SHOULD_BE_COLLECTED} + ${M51328C7_TEST_STATISTICAL_ERROR})
    Should Be True  ${counter_WebEm_value_after} == ${counter_NetAct_value_after}
    Should Be True  ${equation_WebEm}
    Should Be True  ${equation_NetAct}
    log  packets were successfully collected in M51328C7 transport counter on BTS  console=yes
    ${admin_conn}=  Connect to ADMIN
    Delete IPAPP Object From BTS      ${admin_conn}
    Disconnect from ADMIN             ${admin_conn}

[3]CB007672-5G-A-Rate_Limit_for_M-plane_LTE_ipRmDropPcktsRtLimSrLteMplane
    ${counter_id_status}=  Run Keyword And Ignore Error  Get Counter Value From WebEm  M51328C18
    ${counter_id}=  Set Variable If  'PASS' in ${counter_id_status}  M51328C18
    Set Test Variable    ${counter_id}
    Change Rejected Packets Interval and Reporting Interval parameters value to 5 minutes
    Run Keyword And Ignore Error  Check If There Are Any Transport Counter Issues And Reboot BTS If Neened  ${counter_id}
    Wait Until Transport Counters Available After Reboot  ${counter_id}
    Actualize NetAct Counters
    Wait For New Interval Start  ${counter_id}
    ${WebEm_counter_time}=  Get Counter Time From WebEm  ${counter_id}
    ${counter_WebEm_value_before}=  Get Counter Value From WebEm  ${counter_id}
    ${counter_NetAct_value_before}=  Get Counter Value From NetAct  ${counter_id}
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    log  NetAct and WebEm counters time is correct  console=yes
    Remove NetAct Counters Raport
    log  counter value from WebEm before test is ${counter_WebEm_value_before}  console=yes
    log  counter value from NetAct before test is ${counter_NetAct_value_before}  console=yes
    Start Tcpdump For M51328C18 Or M51328C12 Or M51328C7 Counters
    Send Packets For M51328C18 Counter To BTS
    Kill Tcpdump For M51328C18 Or M51328C12 Or M51328C7 Counters
    log  packets were successfully sent on BTS with tcpdump  console=yes
    ${number_of_packets}=  Get Number Of Packets After Packets Flood
    Should Be True  ${number_of_packets} > (${M51328C18_PACKETS} * ${M51328C18_TCPDUMP_STATISTICAL_ERROR_LESS})
    Should Be True  ${number_of_packets} < (${M51328C18_PACKETS} * ${M51328C18_TCPDUMP_STATISTICAL_ERROR_MORE})
    log  packets were successfully collected on BTS with tcpdump  console=yes
    Wait For New Interval Start  ${counter_id}
    ${WebEm_counter_time}=  Get Counter Time From WebEm  ${counter_id}
    ${counter_WebEm_value_after}=  Get Counter Value From WebEm  ${counter_id}
    ${counter_NetAct_value_after}=  Get Counter Value From NetAct  ${counter_id}
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    Remove NetAct Counters Raport
    log  counter value from WebEm after test is ${counter_WebEm_value_after}  console=yes
    log  counter value from NetAct after test is ${counter_NetAct_value_after}  console=yes
    ${equation_WebEm}=  Catenate  (${counter_WebEm_value_after} - ${counter_WebEm_value_before} > ${M51328C18_SHOULD_BE_COLLECTED} -
    ...  ${M51328C18_TEST_STATISTICAL_ERROR}) and (${counter_WebEm_value_after} - ${counter_WebEm_value_before} <
    ...  ${M51328C18_SHOULD_BE_COLLECTED} + ${M51328C18_TEST_STATISTICAL_ERROR})
    ${equation_NetAct}=  Catenate  (${counter_NetAct_value_after} - ${counter_NetAct_value_before} > ${M51328C18_SHOULD_BE_COLLECTED} -
    ...  ${M51328C18_TEST_STATISTICAL_ERROR}) and (${counter_NetAct_value_after} - ${counter_NetAct_value_before} <
    ...  ${M51328C18_SHOULD_BE_COLLECTED} + ${M51328C18_TEST_STATISTICAL_ERROR})
    Should Be True  ${counter_WebEm_value_after} == ${counter_NetAct_value_after}
    Should Be True  ${equation_WebEm}
    Should Be True  ${equation_NetAct}
    log  packets were successfully collected in ${counter_id} transport counter on BTS  console=yes

[3]CB007672-5G-A-Rate_Limit_for_M-plane_LTE_ipRmDropPcktsRtLimSrLteMplane_IPv6
    ${counter_id_status}=  Run Keyword And Ignore Error  Get Counter Value From WebEm  M51328C18
    ${counter_id}=  Set Variable If  'PASS' in ${counter_id_status}  M51328C18  M51328C11
    Set Test Variable    ${counter_id}
    Change Rejected Packets Interval and Reporting Interval parameters value to 5 minutes
    Run Keyword And Ignore Error  Check If There Are Any Transport Counter Issues And Reboot BTS If Neened  ${counter_id}
    Wait Until Transport Counters Available After Reboot  ${counter_id}
    Actualize NetAct Counters
    Wait For New Interval Start  ${counter_id}
    ${WebEm_counter_time}=  Get Counter Time From WebEm  ${counter_id}
    ${counter_WebEm_value_before}=  Get Counter Value From WebEm  ${counter_id}
    ${counter_NetAct_value_before}=  Get Counter Value From NetAct  ${counter_id}
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    log  NetAct and WebEm counters time is correct  console=yes
    Remove NetAct Counters Raport
    log  counter value from WebEm before test is ${counter_WebEm_value_before}  console=yes
    log  counter value from NetAct before test is ${counter_NetAct_value_before}  console=yes
    Start Tcpdump For M51328C18 Or M51328C12 Or M51328C7 Counters
    Send Packets For M51328C18 Counter To BTS IPv6
    Kill Tcpdump For M51328C18 Or M51328C12 Or M51328C7 Counters
    log  packets were successfully sent on BTS with tcpdump  console=yes
    ${number_of_packets}=  Get Number Of Packets After Packets Flood
    Should Be True  ${number_of_packets} > (${M51328C18_PACKETS} * ${M51328C18_TCPDUMP_STATISTICAL_ERROR_LESS})
    Should Be True  ${number_of_packets} < (${M51328C18_PACKETS} * ${M51328C18_TCPDUMP_STATISTICAL_ERROR_MORE})
    log  packets were successfully collected on BTS with tcpdump  console=yes
    Wait For New Interval Start  ${counter_id}
    ${WebEm_counter_time}=  Get Counter Time From WebEm  ${counter_id}
    ${counter_WebEm_value_after}=  Get Counter Value From WebEm  ${counter_id}
    ${counter_NetAct_value_after}=  Get Counter Value From NetAct  ${counter_id}
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    Remove NetAct Counters Raport
    log  counter value from WebEm after test is ${counter_WebEm_value_after}  console=yes
    log  counter value from NetAct after test is ${counter_NetAct_value_after}  console=yes
    ${equation_WebEm}=  Catenate  (${counter_WebEm_value_after} - ${counter_WebEm_value_before} > ${M51328C18_SHOULD_BE_COLLECTED} -
    ...  ${M51328C18_TEST_STATISTICAL_ERROR}) and (${counter_WebEm_value_after} - ${counter_WebEm_value_before} <
    ...  ${M51328C18_SHOULD_BE_COLLECTED} + ${M51328C18_TEST_STATISTICAL_ERROR})
    ${equation_NetAct}=  Catenate  (${counter_NetAct_value_after} - ${counter_NetAct_value_before} > ${M51328C18_SHOULD_BE_COLLECTED} -
    ...  ${M51328C18_TEST_STATISTICAL_ERROR}) and (${counter_NetAct_value_after} - ${counter_NetAct_value_before} <
    ...  ${M51328C18_SHOULD_BE_COLLECTED} + ${M51328C18_TEST_STATISTICAL_ERROR})
    Should Be True  ${counter_WebEm_value_after} == ${counter_NetAct_value_after}
    Should Be True  ${equation_WebEm}
    Should Be True  ${equation_NetAct}
    log  packets were successfully collected in ${counter_id} transport counter on BTS  console=yes

[3]CB007672-5G-A-Rate_Limit_for_Other_Non-M-plane_IP_ipRmDropPcktsRtLimDefault
    Change Rejected Packets Interval and Reporting Interval parameters value to 5 minutes
    Run Keyword And Ignore Error  Check If There Are Any Transport Counter Issues And Reboot BTS If Neened  M51328C12
    Wait Until Transport Counters Available After Reboot  M51328C12
    Actualize NetAct Counters
    Wait For New Interval Start  M51328C12
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C12
    ${counter_WebEm_value_before}=  Get Counter Value From WebEm  M51328C12
    ${counter_NetAct_value_before}=  Get Counter Value From NetAct  M51328C12
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    log  NetAct and WebEm counters time is correct  console=yes
    Remove NetAct Counters Raport
    log  counter value from WebEm before test is ${counter_WebEm_value_before}  console=yes
    log  counter value from NetAct before test is ${counter_NetAct_value_before}  console=yes
    Start Tcpdump For M51328C18 Or M51328C12 Or M51328C7 Counters
    Send Packets For M51328C12 Counter To BTS
    Kill Tcpdump For M51328C18 Or M51328C12 Or M51328C7 Counters
    log  packets were successfully sent on BTS with tcpdump  console=yes
    ${number_of_packets}=  Get Number Of Packets After Packets Flood
    Should Be True  ${number_of_packets} > (${M51328C12_PACKETS} * ${M51328C12_TCPDUMP_STATISTICAL_ERROR_LESS})
    Should Be True  ${number_of_packets} < (${M51328C12_PACKETS} * ${M51328C12_TCPDUMP_STATISTICAL_ERROR_MORE})
    log  packets were successfully collected on BTS with tcpdump  console=yes
    Wait For New Interval Start  M51328C12
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C12
    ${counter_WebEm_value_after}=  Get Counter Value From WebEm  M51328C12
    ${counter_NetAct_value_after}=  Get Counter Value From NetAct  M51328C12
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    Remove NetAct Counters Raport
    log  counter value from WebEm after test is ${counter_WebEm_value_after}  console=yes
    log  counter value from NetAct after test is ${counter_NetAct_value_after}  console=yes
    ${equation_WebEm}=  Catenate  (${counter_WebEm_value_after} - ${counter_WebEm_value_before} > ${M51328C12_SHOULD_BE_COLLECTED} -
    ...  ${M51328C12_TEST_STATISTICAL_ERROR}) and (${counter_WebEm_value_after} - ${counter_WebEm_value_before} <
    ...  ${M51328C12_SHOULD_BE_COLLECTED} + ${M51328C12_TEST_STATISTICAL_ERROR})
    ${equation_NetAct}=  Catenate  (${counter_NetAct_value_after} - ${counter_NetAct_value_before} > ${M51328C12_SHOULD_BE_COLLECTED} -
    ...  ${M51328C12_TEST_STATISTICAL_ERROR}) and (${counter_NetAct_value_after} - ${counter_NetAct_value_before} <
    ...  ${M51328C12_SHOULD_BE_COLLECTED} + ${M51328C12_TEST_STATISTICAL_ERROR})
    Should Be True  ${counter_WebEm_value_after} == ${counter_NetAct_value_after}
    Should Be True  ${equation_WebEm}
    Should Be True  ${equation_NetAct}
    log  packets were successfully collected in M51328C12 transport counter on BTS  console=yes

[3]CB007672-5G-A-Rate_Limit_for_Other_Non-M-plane_IP_ipRmDropPcktsRtLimDefault_IPv6
    Change Rejected Packets Interval and Reporting Interval parameters value to 5 minutes
    Run Keyword And Ignore Error  Check If There Are Any Transport Counter Issues And Reboot BTS If Neened  M51328C12
    Wait Until Transport Counters Available After Reboot  M51328C12
    Actualize NetAct Counters
    Wait For New Interval Start  M51328C12
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C12
    ${counter_WebEm_value_before}=  Get Counter Value From WebEm  M51328C12
    ${counter_NetAct_value_before}=  Get Counter Value From NetAct  M51328C12
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    log  NetAct and WebEm counters time is correct  console=yes
    Remove NetAct Counters Raport
    log  counter value from WebEm before test is ${counter_WebEm_value_before}  console=yes
    log  counter value from NetAct before test is ${counter_NetAct_value_before}  console=yes
    Start Tcpdump For M51328C18 Or M51328C12 Or M51328C7 Counters
    Send Packets For M51328C12 Counter To BTS IPv6
    Kill Tcpdump For M51328C18 Or M51328C12 Or M51328C7 Counters
    log  packets were successfully sent on BTS with tcpdump  console=yes
    ${number_of_packets}=  Get Number Of Packets After Packets Flood
    Should Be True  ${number_of_packets} > (${M51328C12_PACKETS} * ${M51328C12_TCPDUMP_STATISTICAL_ERROR_LESS})
    Should Be True  ${number_of_packets} < (${M51328C12_PACKETS} * ${M51328C12_TCPDUMP_STATISTICAL_ERROR_MORE})
    log  packets were successfully collected on BTS with tcpdump  console=yes
    Wait For New Interval Start  M51328C12
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C12
    ${counter_WebEm_value_after}=  Get Counter Value From WebEm  M51328C12
    ${counter_NetAct_value_after}=  Get Counter Value From NetAct  M51328C12
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    Remove NetAct Counters Raport
    log  counter value from WebEm after test is ${counter_WebEm_value_after}  console=yes
    log  counter value from NetAct after test is ${counter_NetAct_value_after}  console=yes
    ${equation_WebEm}=  Catenate  (${counter_WebEm_value_after} - ${counter_WebEm_value_before} > ${M51328C12_SHOULD_BE_COLLECTED} -
    ...  ${M51328C12_TEST_STATISTICAL_ERROR}) and (${counter_WebEm_value_after} - ${counter_WebEm_value_before} <
    ...  ${M51328C12_SHOULD_BE_COLLECTED} + ${M51328C12_TEST_STATISTICAL_ERROR})
    ${equation_NetAct}=  Catenate  (${counter_NetAct_value_after} - ${counter_NetAct_value_before} > ${M51328C12_SHOULD_BE_COLLECTED} -
    ...  ${M51328C12_TEST_STATISTICAL_ERROR}) and (${counter_NetAct_value_after} - ${counter_NetAct_value_before} <
    ...  ${M51328C12_SHOULD_BE_COLLECTED} + ${M51328C12_TEST_STATISTICAL_ERROR})
    Should Be True  ${counter_WebEm_value_after} == ${counter_NetAct_value_after}
    Should Be True  ${equation_WebEm}
    Should Be True  ${equation_NetAct}
    log  packets were successfully collected in M51328C12 transport counter on BTS  console=yes

[3]CB007672-5G-A-Rate_Limit_for_5G_C-Plane_ipRmDropPcktsRtLim5GCplane
    Change Rejected Packets Interval and Reporting Interval parameters value to 5 minutes
    Run Keyword And Ignore Error  Check If There Are Any Transport Counter Issues And Reboot BTS If Neened  M51328C14
    Wait Until Transport Counters Available After Reboot  M51328C14
    Actualize NetAct Counters
    Wait For New Interval Start  M51328C14
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C14
    ${counter_WebEm_value_before}=  Get Counter Value From WebEm  M51328C14
    ${counter_NetAct_value_before}=  Get Counter Value From NetAct  M51328C14
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    log  NetAct and WebEm counters time is correct  console=yes
    Remove NetAct Counters Raport
    log  counter value from WebEm before test is ${counter_WebEm_value_before}  console=yes
    log  counter value from NetAct before test is ${counter_NetAct_value_before}  console=yes
    Start Tcpdump For M51328C14 Counter
    Send Packets For M51328C14 Counter To BTS
    Kill Tcpdump For M51328C14 Counter
    log  packets were successfully sent on BTS with tcpdump  console=yes
    ${number_of_packets}=  Get Number Of Packets After Packets Flood
    Should Be True  ${number_of_packets} > (${M51328C14_PACKETS} * ${M51328C14_TCPDUMP_STATISTICAL_ERROR_LESS})
    Should Be True  ${number_of_packets} < (${M51328C14_PACKETS} * ${M51328C14_TCPDUMP_STATISTICAL_ERROR_MORE})
    log  packets were successfully collected on BTS with tcpdump  console=yes
    Wait For New Interval Start  M51328C14
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C14
    ${counter_WebEm_value_after}=  Get Counter Value From WebEm  M51328C14
    ${counter_NetAct_value_after}=  Get Counter Value From NetAct  M51328C14
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    Remove NetAct Counters Raport
    log  counter value from WebEm after test is ${counter_WebEm_value_after}  console=yes
    log  counter value from NetAct after test is ${counter_NetAct_value_after}  console=yes
    ${equation_WebEm}=  Catenate  (${counter_WebEm_value_after} - ${counter_WebEm_value_before} > ${M51328C14_SHOULD_BE_COLLECTED} -
    ...  ${M51328C14_TEST_STATISTICAL_ERROR}) and (${counter_WebEm_value_after} - ${counter_WebEm_value_before} <
    ...  ${M51328C14_SHOULD_BE_COLLECTED} + ${M51328C14_TEST_STATISTICAL_ERROR})
    ${equation_NetAct}=  Catenate  (${counter_NetAct_value_after} - ${counter_NetAct_value_before} > ${M51328C14_SHOULD_BE_COLLECTED} -
    ...  ${M51328C14_TEST_STATISTICAL_ERROR}) and (${counter_NetAct_value_after} - ${counter_NetAct_value_before} <
    ...  ${M51328C14_SHOULD_BE_COLLECTED} + ${M51328C14_TEST_STATISTICAL_ERROR})
    Should Be True  ${counter_WebEm_value_after} == ${counter_NetAct_value_after}
    Should Be True  ${equation_WebEm}
    Should Be True  ${equation_NetAct}
    log  packets were successfully collected in M51328C14 transport counter on BTS  console=yes

[3]CB007672-5G-A-Rate_Limit_for_5G_C-Plane_ipRmDropPcktsRtLim5GCplane_IPv6
    Change Rejected Packets Interval and Reporting Interval parameters value to 5 minutes
    Run Keyword And Ignore Error  Check If There Are Any Transport Counter Issues And Reboot BTS If Neened  M51328C14
    Wait Until Transport Counters Available After Reboot  M51328C14
    Actualize NetAct Counters
    Wait For New Interval Start  M51328C14
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C14
    ${counter_WebEm_value_before}=  Get Counter Value From WebEm  M51328C14
    ${counter_NetAct_value_before}=  Get Counter Value From NetAct  M51328C14
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    log  NetAct and WebEm counters time is correct  console=yes
    Remove NetAct Counters Raport
    log  counter value from WebEm before test is ${counter_WebEm_value_before}  console=yes
    log  counter value from NetAct before test is ${counter_NetAct_value_before}  console=yes
    Start Tcpdump For M51328C14 Counter
    Send Packets For M51328C14 Counter To BTS IPv6
    Kill Tcpdump For M51328C14 Counter
    log  packets were successfully sent on BTS with tcpdump  console=yes
    ${number_of_packets}=  Get Number Of Packets After Packets Flood
    Should Be True  ${number_of_packets} > (${M51328C14_PACKETS} * ${M51328C14_TCPDUMP_STATISTICAL_ERROR_LESS})
    Should Be True  ${number_of_packets} < (${M51328C14_PACKETS} * ${M51328C14_TCPDUMP_STATISTICAL_ERROR_MORE})
    log  packets were successfully collected on BTS with tcpdump  console=yes
    Wait For New Interval Start  M51328C14
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C14
    ${counter_WebEm_value_after}=  Get Counter Value From WebEm  M51328C14
    ${counter_NetAct_value_after}=  Get Counter Value From NetAct  M51328C14
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    Remove NetAct Counters Raport
    log  counter value from WebEm after test is ${counter_WebEm_value_after}  console=yes
    log  counter value from NetAct after test is ${counter_NetAct_value_after}  console=yes
    ${equation_WebEm}=  Catenate  (${counter_WebEm_value_after} - ${counter_WebEm_value_before} > ${M51328C14_SHOULD_BE_COLLECTED} -
    ...  ${M51328C14_TEST_STATISTICAL_ERROR}) and (${counter_WebEm_value_after} - ${counter_WebEm_value_before} <
    ...  ${M51328C14_SHOULD_BE_COLLECTED} + ${M51328C14_TEST_STATISTICAL_ERROR})
    ${equation_NetAct}=  Catenate  (${counter_NetAct_value_after} - ${counter_NetAct_value_before} > ${M51328C14_SHOULD_BE_COLLECTED} -
    ...  ${M51328C14_TEST_STATISTICAL_ERROR}) and (${counter_NetAct_value_after} - ${counter_NetAct_value_before} <
    ...  ${M51328C14_SHOULD_BE_COLLECTED} + ${M51328C14_TEST_STATISTICAL_ERROR})
    Should Be True  ${counter_WebEm_value_after} == ${counter_NetAct_value_after}
    Should Be True  ${equation_WebEm}
    Should Be True  ${equation_NetAct}
    log  packets were successfully collected in M51328C14 transport counter on BTS  console=yes

[3]CB007672-5G-A-Rate_Limit_for_ICMP_ipRmDropPcktsRtLimICMP
    Change Rejected Packets Interval and Reporting Interval parameters value to 5 minutes
    Run Keyword And Ignore Error  Check If There Are Any Transport Counter Issues And Reboot BTS If Neened  M51328C15
    Wait Until Transport Counters Available After Reboot  M51328C15
    Actualize NetAct Counters
    Wait For New Interval Start  M51328C15
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C15
    ${counter_WebEm_value_before}=  Get Counter Value From WebEm  M51328C15
    ${counter_NetAct_value_before}=  Get Counter Value From NetAct  M51328C15
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    log  NetAct and WebEm counters time is correct  console=yes
    Remove NetAct Counters Raport
    log  counter value from WebEm before test is ${counter_WebEm_value_before}  console=yes
    log  counter value from NetAct before test is ${counter_NetAct_value_before}  console=yes
    Start Tcpdump For M51328C15 Counter
    Send Packets For M51328C15 Counter To BTS
    Kill Tcpdump For M51328C15 Counter
    log  packets were successfully sent on BTS with tcpdump  console=yes
    ${number_of_packets}=  Get Number Of Packets After Packets Flood
    Should Be True  ${number_of_packets} > (${M51328C15_PACKETS} * ${M51328C15_TCPDUMP_STATISTICAL_ERROR_LESS})
    Should Be True  ${number_of_packets} < (${M51328C15_PACKETS} * ${M51328C15_TCPDUMP_STATISTICAL_ERROR_MORE})
    log  packets were successfully collected on BTS with tcpdump  console=yes
    Wait For New Interval Start  M51328C15
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C15
    ${counter_WebEm_value_after}=  Get Counter Value From WebEm  M51328C15
    ${counter_NetAct_value_after}=  Get Counter Value From NetAct  M51328C15
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    Remove NetAct Counters Raport
    log  counter value from WebEm after test is ${counter_WebEm_value_after}  console=yes
    log  counter value from NetAct after test is ${counter_NetAct_value_after}  console=yes
    ${equation_WebEm}=  Catenate  (${counter_WebEm_value_after} - ${counter_WebEm_value_before} > ${M51328C15_SHOULD_BE_COLLECTED} -
    ...  ${M51328C15_TEST_STATISTICAL_ERROR}) and (${counter_WebEm_value_after} - ${counter_WebEm_value_before} <
    ...  ${M51328C15_SHOULD_BE_COLLECTED} + ${M51328C15_TEST_STATISTICAL_ERROR})
    ${equation_NetAct}=  Catenate  (${counter_NetAct_value_after} - ${counter_NetAct_value_before} > ${M51328C15_SHOULD_BE_COLLECTED} -
    ...  ${M51328C15_TEST_STATISTICAL_ERROR}) and (${counter_NetAct_value_after} - ${counter_NetAct_value_before} <
    ...  ${M51328C15_SHOULD_BE_COLLECTED} + ${M51328C15_TEST_STATISTICAL_ERROR})
    Should Be True  ${counter_WebEm_value_after} == ${counter_NetAct_value_after}
    Should Be True  ${equation_WebEm}
    Should Be True  ${equation_NetAct}
    log  packets were successfully collected in M51328C15 transport counter on BTS  console=yes

[3]CB007672-5G-A-Rate_Limit_for_ICMP_ipRmDropPcktsRtLimICMP_IPv6
    Change Rejected Packets Interval and Reporting Interval parameters value to 5 minutes
    Run Keyword And Ignore Error  Check If There Are Any Transport Counter Issues And Reboot BTS If Neened  M51328C15
    Wait Until Transport Counters Available After Reboot  M51328C15
    Actualize NetAct Counters
    Wait For New Interval Start  M51328C15
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C15
    ${counter_WebEm_value_before}=  Get Counter Value From WebEm  M51328C15
    ${counter_NetAct_value_before}=  Get Counter Value From NetAct  M51328C15
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    log  NetAct and WebEm counters time is correct  console=yes
    Remove NetAct Counters Raport
    log  counter value from WebEm before test is ${counter_WebEm_value_before}  console=yes
    log  counter value from NetAct before test is ${counter_NetAct_value_before}  console=yes
    Start Tcpdump For M51328C15 Counter
    Send Packets For M51328C15 Counter To BTS IPv6
    Kill Tcpdump For M51328C15 Counter
    log  packets were successfully sent on BTS with tcpdump  console=yes
    ${number_of_packets}=  Get Number Of Packets After Packets Flood
    Should Be True  ${number_of_packets} > (${M51328C15_PACKETS} * ${M51328C15_TCPDUMP_STATISTICAL_ERROR_LESS})
    Should Be True  ${number_of_packets} < (${M51328C15_PACKETS} * ${M51328C15_TCPDUMP_STATISTICAL_ERROR_MORE})
    log  packets were successfully collected on BTS with tcpdump  console=yes
    Wait For New Interval Start  M51328C15
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C15
    ${counter_WebEm_value_after}=  Get Counter Value From WebEm  M51328C15
    ${counter_NetAct_value_after}=  Get Counter Value From NetAct  M51328C15
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    Remove NetAct Counters Raport
    log  counter value from WebEm after test is ${counter_WebEm_value_after}  console=yes
    log  counter value from NetAct after test is ${counter_NetAct_value_after}  console=yes
    ${equation_WebEm}=  Catenate  (${counter_WebEm_value_after} - ${counter_WebEm_value_before} > ${M51328C15_SHOULD_BE_COLLECTED} -
    ...  ${M51328C15_TEST_STATISTICAL_ERROR}) and (${counter_WebEm_value_after} - ${counter_WebEm_value_before} <
    ...  ${M51328C15_SHOULD_BE_COLLECTED} + ${M51328C15_TEST_STATISTICAL_ERROR})
    ${equation_NetAct}=  Catenate  (${counter_NetAct_value_after} - ${counter_NetAct_value_before} > ${M51328C15_SHOULD_BE_COLLECTED} -
    ...  ${M51328C15_TEST_STATISTICAL_ERROR}) and (${counter_NetAct_value_after} - ${counter_NetAct_value_before} <
    ...  ${M51328C15_SHOULD_BE_COLLECTED} + ${M51328C15_TEST_STATISTICAL_ERROR})
    Should Be True  ${counter_WebEm_value_after} == ${counter_NetAct_value_after}
    Should Be True  ${equation_WebEm}
    Should Be True  ${equation_NetAct}
    log  packets were successfully collected in M51328C15 transport counter on BTS  console=yes
