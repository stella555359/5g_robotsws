# *** Settings ***
# Suite Setup          IPSEC cOAM Common Suite Setup
# Suite Teardown       IPSEC cOAM Common Suite Teardown
# Test Setup
# Test Teardown
# Test Timeout      20mins
# 
# Resource          Resource/5GC001545_YA_Keyword.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Documentation
# ...    author: zora.zhang
# ...    contact: zora.zhang@nokia-sbell.com
# ...    squad group: SG_05
# ...    Feature 5GC001545-YA in 5G19B program
# 
# Force Tags    CA_5G_OAM      
# ...    PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]5GC001545-YA_5GC001213_05_Basic_U_C_M_planes_mapping_to_different_VLANs_with_IPV4_tunnel
#     [Documentation]    *****************
#     ...    Basic information
#     ...    *****************
#     ...    - gNB Basic IPSec support 3 vlan with ipv4 tunnel
#     ...    *****************
#     ...    Description in reStructuredText format on what is tested
#     ...    *****************
#     ...    - [TEST PURPOSE] To verify gNB Basic IPSec support 3 vlan with ipv4 tunnel
#     ...    ******************
#     ...    History of changes
#     ...    ******************
#     ...    - 20.05.2019   https://jiradc.int.net.nokia.com/browse/WESTLAKE-1055    - Created
#     ...    - - Modify
#     ...    *******************
#     ...    Test case flowchart
#     ...    *******************
#     [Tags]    Classicalbts    Owner_zora.zhang@nokia-sbell.com     CRT_TRUNK     CIT_22R1    CRT_22R3
#     [Setup]   Run Keywords    IPSEC cOAM Common Test Setup    AND    Requset Configuration Id Report
#     Step1: Check ipsec tunnel connection is up
#     Step2: Make traffic from leftsubnet to rightsubnet
#     [Teardown]    Run Keywords    Teardown    AND   CI_interface.Common Case Teardown
# 
# 
# *** Keywords ***
# Teardown
#     #selenium.logout
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
#     should contain    ${ipsec_conf}    conn4
#     should contain    ${ipsec_conf}    conn5
#     should contain    ${ipsec_conf}    conn8
#     csn.disconnect    connection=gNB
# 
# Check ipsec tunnel is up
#     csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gNB
#     sleep    5s
#     #csn.send_command    command=ipsec restart    connection=gNB
#     sleep    10s
#     csn.send_command    command=ipsec statusall    connection=gNB
#     sleep    3s
#     ${ipsecstatu}    csn.read output    connection=gNB
#     should match regexp    ${ipsecstatu}    conn4\[[0-9999999]*\]: ESTABLISHED
#     should match regexp    ${ipsecstatu}    conn4\[[0-9999999]*\]: IKE proposal: AES_CBC_128
#     should match regexp    ${ipsecstatu}    conn4\{[0-999999]*\}:  AES_CBC_128
#     should match regexp    ${ipsecstatu}    conn5\[[0-9999999]*\]: ESTABLISHED
#     should match regexp    ${ipsecstatu}    conn5\[[0-9999999]*\]: IKE proposal: AES_CBC_128
#     should match regexp    ${ipsecstatu}    conn5\{[0-999999]*\}:  AES_CBC_128
#     should match regexp    ${ipsecstatu}    conn8\[[0-9999999]*\]: ESTABLISHED
#     should match regexp    ${ipsecstatu}    conn8\[[0-9999999]*\]: IKE proposal: 3DES_CBC
#     should match regexp    ${ipsecstatu}    conn8\{[0-999999]*\}:  3DES_CBC
#     csn.disconnect    connection=gNB
# 
# Ping gnb subnet to 7750 subnet
#     csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gNB
#     #csn.send_command    command=ipsec restart    connection=gNB
#     sleep    1min
#     csn.send_command    command=ping -I ${gnb_Mplane} ${switch_subnet1} -c 5    connection=gNB
#     sleep    3s
#     ${ipsec_ping_info1}    csn.read output    connection=gNB
#     should contain    ${ipsec_ping_info1}    PING ${switch_subnet1} (${switch_subnet1}) from ${gnb_Mplane}
#     should contain    ${ipsec_ping_info1}    64 bytes from ${switch_subnet1}: icmp_seq
#     sleep    3s
# 
#     csn.send_command    command=ping -I ${gnb_X2Uplane} ${switch_subnet1} -c 5    connection=gNB
#     sleep    3s
#     ${ipsec_ping_info2}    csn.read output    connection=gNB
#     should contain    ${ipsec_ping_info2}    PING ${switch_subnet1} (${switch_subnet1}) from ${gnb_X2Uplane}
#     should contain    ${ipsec_ping_info2}    64 bytes from ${switch_subnet1}: icmp_seq
#     sleep    3s
# 
#     csn.send_command    command=ping -I ${gnb_S1Uplane} ${switch_subnet1} -c 5    connection=gNB
#     sleep    3s
#     ${ipsec_ping_info3}    csn.read output    connection=gNB
#     should contain    ${ipsec_ping_info3}    PING ${switch_subnet1} (${switch_subnet1}) from ${gnb_S1Uplane}
#     should contain    ${ipsec_ping_info3}    64 bytes from ${switch_subnet1}: icmp_seq
#     sleep    3s
# 
#     csn.disconnect    connection=gNB
# 
