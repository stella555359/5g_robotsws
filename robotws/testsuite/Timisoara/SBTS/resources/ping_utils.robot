*** Settings ***
Documentation  Ping Utils

Library     taf.sw.ping  WITH NAME  ping

*** Keywords ***
Check If Target IP Is Reachable
    [Arguments]    ${ip_address}
    [Documentation]
    ...  This KW check if target IP is pingable
    ...  example of simple use:  Check If Target IP Is Reachable  192.168.255.129
    ...  *AUTHOR*
    ...  jakub.kokoszka@nokia.com

    Log  Check if IP=${ip_address} address is reachable  console=${True}
    ${is_ping}    ping.Ip Is Pingable    ${ip_address}
    Run Keyword If    '${is_ping}'=='False'    Fail    IP address=${ip_address} is not reachable
    Log  IP address=${ip_address} is reachable  console=${True}

Wait For Target IP To Be Reachable
    [Arguments]    ${ip_address}    ${waiting_time_in_min}=1
    [Documentation]
    ...  This KW check if target IP is pingable
    ...  example of simple use:  Wait For Target IP To Be Reachable  192.168.255.129
    ...  waiting time in min by default = 1 min
    ...  example of simple use:  Wait For Target IP To Be Reachable  192.168.255.129  3
    ...  KW waits for ping time given in arguments. If not specified waits 1min by default.
    ...  *AUTHOR*
    ...  jakub.kokoszka@nokia.com

    Wait Until Keyword Succeeds  ${waiting_time_in_min}m  10s  Check If Target IP Is Reachable    ${ip_address}

Check If Host Is Not Pingable
    [Arguments]    ${host_ip_address}
	${out_ping_result}=    Run    ping -c 1 -W 10 ${host_ip_address}
    Should Contain    ${out_ping_result}    1 packets transmitted, 0 received    timeout=5
    [Return]    ${out_ping_result}

Wait For Target IP To Be Unreachable
    [Arguments]    ${ip_address}    ${waiting_time_in_min}=1
    [Documentation]
    ...  This KW check if target IP is pingable
    ...  example of simple use:  Wait For Target IP To Be Unreachable  192.168.255.129
    ...  waiting time in min by default = 1 min
    ...  example of simple use:  Wait For Target IP To Be Unreachable  192.168.255.129  3
    ...  KW waits for ping time given in arguments. If not specified waits 1min by default.
    ...  *AUTHOR*
    ...  jakub.kokoszka@nokia.com

    Wait Until Keyword Succeeds  ${waiting_time_in_min}m  10s  Check If Host Is Not Pingable    ${ip_address}
