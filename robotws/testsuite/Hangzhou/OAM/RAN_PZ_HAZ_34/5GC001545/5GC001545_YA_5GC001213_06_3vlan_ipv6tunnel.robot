# *** Settings ***
# Suite Setup          IPSEC cOAM Common Suite Setup
# Suite Teardown       IPSEC cOAM Common Suite Teardown
# Test Setup
# Test Teardown
# Test Timeout      20mins
# 
# Resource    ./Resource/5GC001545_YA_Keyword.robot
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
# [1]5GC001545-YA_5GC001213_06_Basic_U_C_M_planes_mapping_to_different_VLANs_with_IPV6_tunnel
#     [Documentation]    *****************
#     ...    Basic information
#     ...    *****************
#     ...    - gNB Basic IPSec support 3 vlan with ipv6 tunnel
#     ...    *****************
#     ...    Description in reStructuredText format on what is tested
#     ...    *****************
#     ...    - [TEST PURPOSE] To verify gNB Basic IPSec support 3 vlan with ipv6 tunnel
#     ...    ******************
#     ...    History of changes
#     ...    ******************
#     ...    - 20.05.2019   https://jiradc.int.net.nokia.com/browse/WESTLAKE-1057    - Created
#     ...    - - Modify
#     ...    *******************
#     ...    Test case flowchart
#     ...    *******************
#     [Tags]    Classicalbts    Owner_zora.zhang@nokia-sbell.com     CRT_TRUNK
#     [Setup]    Run Keywords    IPSEC cOAM Common Test Setup    AND    Requset Configuration Id Report
#     Step1: Check ipsec tunnel connection is up
#     Step2: Make traffic from leftsubnet to rightsubnet
#     [Teardown]    Run Keywords    Teardown   AND     CI_interface.Common Case Teardown
# 
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
#     should contain    ${ipsec_conf}    conn7
#     should contain    ${ipsec_conf}    conn9
#     csn.disconnect    connection=gNB
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
#     should match regexp    ${ipsecstatu}    conn7\[[0-9999999]*\]: ESTABLISHED
#     should match regexp    ${ipsecstatu}    conn7\[[0-9999999]*\]: IKE proposal: 3DES_CBC
#     should match regexp    ${ipsecstatu}    conn7\{[0-999999]*\}:  AES_CBC_128
# 
#     should match regexp    ${ipsecstatu}    conn9\[[0-9999999]*\]: ESTABLISHED
#     should match regexp    ${ipsecstatu}    conn9\[[0-9999999]*\]: IKE proposal: AES_CBC_128
#     should match regexp    ${ipsecstatu}    conn9\{[0-9999999]*\}:  AES_CBC_128
# 
#     Run Keyword And Ignore Error    csn.disconnect    connection=gNB
# 
# 
# Ping gnb subnet to 7750 subnet
#     csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gNB
#     #csn.send_command    command=ipsec restart    connection=gNB
#     sleep    1min
#     set suite variable    ${switch_subnet1}
#     csn.send_command    command=ping -6 -I ${gnb_S1Uplanev6} ${switch_subnet1v6} -c 5    connection=gNB
#     sleep    5s
#     ${ipsec_ping_info4}    csn.read output    connection=gNB
#     should contain    ${ipsec_ping_info4}    PING  ${switch_subnet1v6}( ${switch_subnet1v6}) from ${gnb_S1Uplanev6}
#     should contain    ${ipsec_ping_info4}    64 bytes from ${switch_subnet1v6}
#     #should contain    ${ipsec_ping_info4}    5 packets transmitted, 5 received, 0% packet loss
#     sleep    3s
# 
#     csn.send_command    command=ping -6 -I ${gnb_Mplanev6} ${switch_subnet1v6} -c 5    connection=gNB
#     sleep    5s
#     ${ipsec_ping_info5}    csn.read output    connection=gNB
#     should contain    ${ipsec_ping_info5}    PING ${switch_subnet1v6}(${switch_subnet1v6}) from ${gnb_Mplanev6}
#     should contain    ${ipsec_ping_info5}    64 bytes from ${switch_subnet1v6}
#     #should contain    ${ipsec_ping_info5}    5 packets transmitted, 5 received, 0% packet loss
#     sleep    3s
# 
#     csn.send_command    command=ping -6 -I ${gnb_X2Uplanev6} ${switch_subnet1v6} -c 5    connection=gNB
#     sleep    5s
#     ${ipsec_ping_info6}    csn.read output    connection=gNB
#     should contain    ${ipsec_ping_info6}    PING ${switch_subnet1v6}(${switch_subnet1v6}) from ${gnb_X2Uplanev6}
#     should contain    ${ipsec_ping_info6}    64 bytes from ${switch_subnet1v6}
#     #should contain    ${ipsec_ping_info6}    5 packets transmitted, 5 received, 0% packet loss
#     sleep    3s
#     run keyword and ignore error    csn.disconnect    connection=gNB
