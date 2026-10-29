# *** Settings ***
# Suite Setup       #Common Suite Setup
# Suite Teardown    #Common Suite Teardown
# Test Setup        #Common Test Setup
# Test Teardown
# Test Timeout      1 hour
# 
# Resource          Resource/5GC001526_EA_Keyword.robot
# 
# Documentation
# ...    author: wei.2.duan
# ...    contact: wei.2.duan@nokia-sbell.com
# ...    squad group: SG_05
# ...    Feature 5GC001526-EA in 5G19A program
# 
# Force Tags    CA_5G_OAM    
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
#     [Tags]    Owner_wei.2.duan@nokia-sbell.com   CRT_22R2   CRT_22R4
#     [Setup]   selenium_coam.enable_virtual_display
#     "Step1": Check ipsec tunnel connection is up
#     "Step2": Make traffic from leftsubnet to rightsubnet
#     [Teardown]    Teardown
# 
# *** Keywords ***
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
#     #sleep    10s
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
#     should match regexp    ${ipsecstatu}    conn8\[[0-999999]*\]: IKE proposal: AES_CBC_128
#     should match regexp    ${ipsecstatu}    conn8\{[0-999999]*\}:  AES_CBC_128
#     Run Keyword And Ignore Error    csn.disconnect    connection=gNB
# 
# 
# Ping gnb subnet to 7750 subnet
#     csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gNB
#     sleep    3s
#     set suite variable    ${switch_subnet1}
#     csn.send_command    command=ping -6 -I ${gnb_S1Uplanev6} ${switch_subnet1v6} -c 5    connection=gNB
#     sleep    3s
#     ${ipsec_ping_info4}    csn.read output    connection=gNB
#     should contain    ${ipsec_ping_info4}    PING ${switch_subnet1v6}(${switch_subnet1v6}) from ${gnb_S1Uplanev6}
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
