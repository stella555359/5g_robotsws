*** Settings ***
Documentation
...    Author: Xu Yuyan
...    Email address: yuyan.xu@nokia-sbell.com
...    Maintainer: yuyan.xu@nokia-sbell.com

Library             OperatingSystem
Library             SSHLibrary

#*** Test Cases ***
#Gateway_Setting_For_IPSec
#    Check_IPs_Pingable     10.69.236.252    10.69.236.253    10.69.236.254    VRF1_T8_eNB1907

*** Keywords ***
Check_IPs_Pingable
    [Arguments]    ${ip1}    ${ip2}    ${ip3}    ${tunnel_id}    ${gateway_ip}=10.106.215.43
    ${ping_result}    Set Variable    ${False}
    ${rc}    ${result}    OperatingSystem.Run And Return Rc And Output    ping -c 5 -w 10 ${ip1}
    ${ping_status1}    Evaluate    ${rc}==${0}
    Sleep    2s
    ${rc}    ${result}    OperatingSystem.Run And Return Rc And Output    ping -c 5 -w 10 ${ip2}
    ${ping_status2}    Evaluate    ${rc}==${0}
    Sleep    2s
    ${rc}    ${result}    OperatingSystem.Run And Return Rc And Output    ping -c 5 -w 10 ${ip3}
    ${ping_status3}    Evaluate    ${rc}==${0}
    Sleep    2s
    ${ping_result}    Set Variable If    ${ping_status1} and ${ping_status2} and ${ping_status1}    ${True}    ${ping_result}
    Run Keyword Unless    ${ping_result}    Wait Until Keyword Succeeds    10x    10 sec
    ...    Gateway_Setting    ${ip1}    ${ip2}    ${ip3}    ${tunnel_id}    ${gateway_ip}
    Sleep    30s

Gateway_Setting
    [Arguments]    ${ip1}    ${ip2}    ${ip3}    ${tunnel_id}    ${gateway_ip}=10.106.215.43
    ${ssh_index}    SSHLibrary.Open Connection    host=10.56.111.85    prompt=$    alias=connect_gateway
    SSHLibrary.Login    ute    Ut3pa5s#ff97
    ${output}    Execute CMD Via SSH connection2    ssh admin@${gateway_ip}    password
    ${output}    Execute CMD Via SSH connection2    admin    \#
    ${output}    Execute CMD Via SSH connection2    diagnose vpn tunnel down ${tunnel_id}    \#
    sleep    2s
    ${output}    Execute CMD Via SSH connection2    diagnose vpn tunnel down ${tunnel_id}    \#
    sleep    2s
    ${output}    Execute CMD Via SSH connection2    diagnose vpn tunnel down ${tunnel_id}    \#
    sleep    2s
    ${output}    Execute CMD Via SSH connection2    diagnose vpn tunnel list name ${tunnel_id}    \#
    Should Contain    ${output}    dst: 0:${ip1}-${ip1}:0
    Should Contain    ${output}    dst: 0:${ip2}-${ip2}:0
    Should Contain    ${output}    dst: 0:${ip3}-${ip3}:0
    Sleep    10s
    Wait Until Keyword Succeeds    10x    30 sec   Test_Pingable    ${ip1}    ${ip2}    ${ip3}

Execute CMD Via SSH connection2
    [Arguments]    ${cmd}    ${expect_console}    ${index_or_alias}=${None}    ${console_delay}=2s
    Run Keyword Unless    ${index_or_alias} is None    SSHLibrary.Switch Connection    ${index_or_alias}
    SSHLibrary.Write    ${cmd}
    ${output}    Wait Until Keyword Succeeds    3x    ${console_delay}    SSHLibrary.Read Until Regexp    ${expect_console}
    [Return]    ${output}

Test_Pingable
    [Arguments]    ${ip1}    ${ip2}    ${ip3}
    ${ping_result}    Set Variable    ${False}
    ${rc}    ${result}    OperatingSystem.Run And Return Rc And Output    ping -c 5 -w 10 ${ip1}
    ${ping_status1}    Evaluate    ${rc}==${0}
    Sleep    2s
    ${rc}    ${result}    OperatingSystem.Run And Return Rc And Output    ping -c 5 -w 10 ${ip2}
    ${ping_status2}    Evaluate    ${rc}==${0}
    Sleep    2s
    ${rc}    ${result}    OperatingSystem.Run And Return Rc And Output    ping -c 5 -w 10 ${ip3}
    ${ping_status3}    Evaluate    ${rc}==${0}
    Sleep    2s
    Should Be True    ${ping_status1} and ${ping_status2} and ${ping_status1}