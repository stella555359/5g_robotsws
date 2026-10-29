# *** Settings ***
# Suite Setup          #Common Suite Setup
# Suite Teardown       #Common Suite Teardown
# Test Setup           #Run Keywords        selenium_coam.enable_virtual_display
# Test Teardown        #Run Keyword    Teardown
# Test Timeout         1 hour
# 
# Resource             Resource/5GC001526_EA_Keyword.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Documentation
# ...    author: wei.2.duan
# ...    contact: wei.2.duan@nokia-sbell.com
# ...    squad group: SG_05
# ...    Feature 5GC001526-EA in 5G19A program
# 
# Force Tags    CA_5G_OAM      CRT
# ...    PY36
# 
# 
# *** Variables ***
# 
# 
# *** Test Cases ***
# [1]5GC001526_EA_5GC000264_IPSec shall support ipv4 and ipv6 dual stack
#     [Documentation]    *****************
#     ...    Basic information
#     ...    *****************
#     ...    - gNB IPSec shall support ipv4 and ipv6 dual stack
#     ...    *****************
#     ...    Description in reStructuredText format on what is tested
#     ...    *****************
#     ...    - [TEST PURPOSE] To verify gNB IPSec shall support ipv4 and ipv6 dual stack
#     ...    ******************
#     ...    History of changes
#     ...    ******************
#     ...    - 20.05.2019   https://jiradc.int.net.nokia.com/browse/WESTLAKE-1042    - Created
#     ...    - - Modify
#     ...    *******************
#     ...    Test case flowchart
#     ...    *******************
#     [Tags]        AUTHOR_wei.2.duan@nokia-sbell.com    CRT_TRUNK   SBTS00
#     [Setup]    Run Keywords    selenium_coam.enable_virtual_display    AND   Requset Configuration Id Report
#     [Teardown]    Run Keywords    Teardown    AND   CI_interface.Common Case Teardown
#     Step1: Check ipsec tunnel connection is up
#     Step2: Make traffic from leftsubnet to rightsubnet
# 
# *** Keywords ***
# Teardown
#     #WEBUI Logout
#     Run Keyword And Ignore Error    selenium_coam.disable_virtual_display
# 
# Step1: Check ipsec tunnel connection is up
#     log to console    Step1: Check ipsec tunnel connection is up
#     wait until keyword succeeds    10min    1min    Check left gnb status with command
#     ${result_1}    Run Keyword And Ignore Error    Check ipsec tunnel is up
#     ${result_2}    Run Keyword And Ignore Error    Check ipsec conf exist
#     Run Keyword If     "${result_1[0]}" == "FAIL" or "${result_2[0]}" == "FAIL"    Run Keywords
#     ...    Import ipsec commission file    AND    Check ipsec tunnel is up
#     sleep    3s
# 
# Step2: Make traffic from leftsubnet to rightsubnet
#     log to console    Step2: Make traffic from leftsubnet to rightsubnet
#     Ping gnb subnet to 7750 subnet
# 
# Check ipsec conf exist
#     csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gNB
#     csn.send_command    command=cat /etc/ipsec.conf    connection=gNB
#     sleep    3s
#     ${ipsec_conf}    csn.read output    connection=gNB
#     sleep    3s
#     should contain    ${ipsec_conf}    conn1
#     should contain    ${ipsec_conf}    conn8
#     Run Keyword And Ignore Error    csn.disconnect    connection=gNB
# 
# Check ipsec tunnel is up
#     csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gNB
#     sleep    5s
#     #csn.send_command    command=ipsec restart    connection=gNB
#     sleep    10s
#     csn.send_command    command=ipsec statusall    connection=gNB
#     #csn.send_command    command=ipsec statusall > ${gnb_ipsec_status}   connection=gNB
#     sleep    3s
#     #csn.send_command    command=cat ${gnb_ipsec_status}   connection=gNB
#     ${ipsecstatu}    csn.read output    connection=gNB
#     should match regexp    ${ipsecstatu}    conn1\[[0-9999999]*\]: ESTABLISHED
#     should match regexp    ${ipsecstatu}    conn1\[[0-9999999]*\]: IKE proposal: AES_CBC_128
#     should match regexp    ${ipsecstatu}    conn1\{[0-999999]*\}:  AES_CBC_128
#     
#     should match regexp    ${ipsecstatu}    conn8\[[0-9999999]*\]: ESTABLISHED
#     should match regexp    ${ipsecstatu}    conn8\[[0-999999]*\]: IKE proposal: 3DES_CBC
#     should match regexp    ${ipsecstatu}    conn8\{[0-999999]*\}:  3DES_CBC
#     Run Keyword And Ignore Error    csn.disconnect    connection=gNB
# 
# 
# Ping gnb subnet to 7750 subnet
#     csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gNB
#     sleep    15s
#     set suite variable    ${switch_subnet1}
#     csn.send_command    command=ping -6 -I ${gnb_Mplanev6} ${switch_subnet1v6} -c 5    connection=gNB
#     sleep    3s
#     ${ipsec_ping_info4}    csn.read output    connection=gNB
#     should contain    ${ipsec_ping_info4}    PING ${switch_subnet1v6}(${switch_subnet1v6}) from ${gnb_Mplanev6}
#     should contain    ${ipsec_ping_info4}    64 bytes from ${switch_subnet1v6}
#     #should contain    ${ipsec_ping_info4}    5 packets transmitted, 5 received, 0% packet loss
#     sleep    3s
#     
#     csn.send_command    command=ping -I ${gnb_S1Uplane} ${switch_subnet1} -c 5    connection=gNB
#     sleep    3s
#     ${ipsec_ping_info1}    csn.read output    connection=gNB
#     should contain    ${ipsec_ping_info1}    PING ${switch_subnet1} (${switch_subnet1}) from ${gnb_S1Uplane}
#     should contain    ${ipsec_ping_info1}    64 bytes from ${switch_subnet1}: icmp_seq
#     sleep    3s
#     run keyword and ignore error    csn.disconnect    connection=gNB
