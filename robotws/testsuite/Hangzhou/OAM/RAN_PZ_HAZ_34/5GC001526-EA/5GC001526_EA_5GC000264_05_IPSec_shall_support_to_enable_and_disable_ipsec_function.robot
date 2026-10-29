# *** Settings ***
# Suite Setup          #Common Suite Setup
# Suite Teardown       #Common Suite Teardown
# Test Setup           Run Keywords        selenium_coam.enable_virtual_display
# Test Teardown        Run Keyword    Teardown
# Test Timeout      1 hour
# 
# Resource          ${CURDIR}/Resource/5GC001526_EA_Keyword.robot
# 
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
# *** Variables ***
# ${dist_name}           MRBTS-${MRBTS_ID}/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1
# ${search_text}         	IPsec enabling switch
# ${new_value}            false
# ${old_value}            true
# 
# *** Test Cases ***
# [1]5GC001526_EA_5GC000264_IPSec shall support to enable and disable ipsec function
#     [Documentation]    *****************
#     ...    Basic information
#     ...    *****************
#     ...    - gNB IPSec shall support to enable and disable ipsec function
#     ...    *****************
#     ...    Description in reStructuredText format on what is tested
#     ...    *****************
#     ...    - [TEST PURPOSE] To verify gNB IPSec shall support to enable and disable ipsec function
#     ...    ******************
#     ...    History of changes
#     ...    ******************
#     ...    - 20.05.2019   https://jiradc.int.net.nokia.com/browse/WESTLAKE-1051    - Created
#     ...    - - Modify
#     ...    *******************
#     ...    Test case flowchart
#     ...    *******************
#     [Tags]    Owner_wei.2.duan@nokia-sbell.com    CIT_22R1    CRT_22R3
# 
#     Step1: Check ipsec tunnel connection is up
#     Step2: Make traffic from leftsubnet to rightsubnet
#     Step3: Disable ipsec via webEM
#     Step4: Check ipsec tunnel connection is down
#     Step5: Make traffic from leftsubnet to rightsubnet fail
#     Step6: Enable ipsec via webEM
#     Step7: Check ipsec tunnel connection is up
#     Step8: Make traffic from leftsubnet to rightsubnet
# 
# *** Keywords ***
# Teardown
#     Recover ipsec Enable
# 	Run Keyword And Ignore Error    selenium_coam.disable_virtual_display
# 
# Step1: Check ipsec tunnel connection is up
#     log to console    Step1: Check ipsec tunnel connection is up
#     wait until keyword succeeds    10min    1min    Check ASIK status with command
# 	${result_1}    Run Keyword And Ignore Error    Check ipsec tunnel is up
#     ${result_2}    Run Keyword And Ignore Error    Check ipsec conf exist
# 	Run Keyword If     "${result_1[0]}" == "FAIL" or "${result_2[0]}" == "FAIL"    Run Keywords
#     ...    Import ipsec commission file    AND    Check ipsec tunnel is up
#     sleep    3s
# 
# Step2: Make traffic from leftsubnet to rightsubnet
#     log to console    Step2: Make traffic from leftsubnet to rightsubnet
#     Ping gnb subnet to 7750 subnet success
# 
# Step3: Disable ipsec via webEM
#     log to console    Step3: Disable ipsec via webEM
#     wait until keyword succeeds    10min    1min    WEBUI Login
#     selenium_coam.disable_screen_lock
#     selenium_coam.set_parameter_value    ${dist_name}    ${search_text}    ${new_value}
#     Validate and activate and check activate plan status
#     sleep    3s
# 
# Step4: Check ipsec tunnel connection is down
#     log to console    Step4: Check ipsec tunnel connection is down
#     Check ipsec tunnel is down
# 
# Step5: Make traffic from leftsubnet to rightsubnet fail
#     log to console    Step5: Make traffic from leftsubnet to rightsubnet
#     Ping gnb subnet to 7750 subnet fail
# 
# Step6: Enable ipsec via webEM
#     log to console    Step6: Enable ipsec via webEM
#     Set ipsec enable
#     WEBUI Logout
# 
# Step7: Check ipsec tunnel connection is up
#     log to console    Step7: Check ipsec tunnel connection is up
#     Check ipsec tunnel is up
# 
# Step8: Make traffic from leftsubnet to rightsubnet
#     log to console    Step8: Make traffic from leftsubnet to rightsubnet
#     Ping gnb subnet to 7750 subnet success
# 
# 
# Set ipsec enable
#     selenium_coam.set_parameter_value    ${dist_name}    ${search_text}    ${old_value}
#     Validate and activate and check activate plan status
#     sleep    3s
# 
# Check ipsec conf exist
#     csn.connect to    ${asik_addr}    ${asik_username}    ${asik_password}    alias=gNB
#     csn.send_command    command=cat /etc/ipsec.conf    connection=gNB
#     sleep    3s
#     ${ipsec_conf}    csn.read output    connection=gNB
#     sleep    3s
#     should contain    ${ipsec_conf}    conn3
#     should contain    ${ipsec_conf}    conn8
#     csn.disconnect    connection=gNB
# 
# Check ipsec tunnel is up
#     csn.connect to    ${asik_addr}    ${asik_username}    ${asik_password}    alias=gNB
# 	sleep    5s
#     #csn.send_command    command=ipsec restart    connection=gNB
#     sleep    10s
#     csn.send_command    command=ipsec statusall    connection=gNB
#     sleep    3s
#     ${ipsecstatu}    csn.read output    connection=gNB
#     should match regexp    ${ipsecstatu}    conn3\[[0-9999999]*\]: ESTABLISHED
#     should match regexp    ${ipsecstatu}    conn3\{[0-999999]*\}:  ${gnb_X2Cplane}/32 === ${switch_subnet2}/32
# 	
# 	should match regexp    ${ipsecstatu}    conn8\[[0-9999999]*\]: ESTABLISHED
#     should match regexp    ${ipsecstatu}    conn8\{[0-999999]*\}:  ${gnb_S1Uplane}/32 === ${switch_subnet3}/30
#     csn.disconnect    connection=gNB
# 
# Ping gnb subnet to 7750 subnet success
#     csn.connect to    ${asik_addr}    ${asik_username}    ${asik_password}    alias=gNB
#     #csn.send_command    command=ipsec restart    connection=gNB
#     sleep    5s
#     set suite variable    ${switch_subnet1}
#     csn.send_command    command=ping -I ${gnb_S1Uplane} ${switch_subnet1} -c 5    connection=gNB
#     sleep    3s
#     ${ipsec_ping_info1}    csn.read output    connection=gNB
#     should contain    ${ipsec_ping_info1}    PING ${switch_subnet1} (${switch_subnet1}) from ${gnb_S1Uplane}
#     should contain    ${ipsec_ping_info1}    64 bytes from ${switch_subnet1}: icmp_seq
#     sleep    3s
# 
#     csn.send_command    command=ping -I ${gnb_X2Cplane} ${switch_subnet2} -c 5    connection=gNB
#     sleep    3s
#     ${ipsec_ping_info2}    csn.read output    connection=gNB
#     should contain    ${ipsec_ping_info2}    PING ${switch_subnet2} (${switch_subnet2}) from ${gnb_X2Cplane}
#     should contain    ${ipsec_ping_info2}    64 bytes from ${switch_subnet2}: icmp_seq
#     sleep    3s
#     run keyword and ignore error    csn.disconnect    connection=gNB
# 
# Ping gnb subnet to 7750 subnet fail
#     csn.connect to    ${asik_addr}    ${asik_username}    ${asik_password}    alias=gNB
#     sleep    3s
#     set suite variable    ${switch_subnet1}
#     csn.send_command    command=ping -I ${gnb_S1Uplane} ${switch_subnet1} -c 5    connection=gNB
#     sleep    3s
#     ${ipsec_ping_info12}    csn.read output    connection=gNB
#     should contain    ${ipsec_ping_info12}    PING ${switch_subnet1} (${switch_subnet1}) from ${gnb_S1Uplane}
#     should contain    ${ipsec_ping_info12}    5 packets transmitted, 0 received, 100% packet loss
#     sleep   3s
# 
#     csn.send_command    command=ping -I ${gnb_X2Cplane} ${switch_subnet2} -c 5    connection=gNB
#     sleep    3s
#     ${ipsec_ping_info9}    csn.read output    connection=gNB
#     should contain    ${ipsec_ping_info9}    PING ${switch_subnet2} (${switch_subnet2}) from ${gnb_X2Cplane}
#     should contain    ${ipsec_ping_info9}    5 packets transmitted, 0 received, 100% packet loss
#     sleep    3s
#     run keyword and ignore error    csn.disconnect    connection=gNB
# 
# Recover ipsec Enable
#     log to console    teardown: Recover ipsec lifetime vlaue
#     wait until keyword succeeds    10min    1min    WEBUI Login
#     ${online_value}    selenium_coam.get_parameter_value    ${dist_name}    ${search_text}
# 	set suite variable    ${online_value}
#     sleep    3s
# 	Run Keyword If     "${online_value}" == "${old_value}"    Log    \n**sueccess**\n
#     ...    ELSE    Set ipsec enable
# 	sleep    10s
# 	WEBUI Logout
