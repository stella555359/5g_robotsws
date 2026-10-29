# *** Settings ***
# Suite Setup          #Common Suite Setup
# Suite Teardown       #Common Suite Teardown
# Test Setup           Run Keyword    selenium_coam.enable_virtual_display    #Common Test Setup
# Test Teardown        Run Keyword    Teardown
# Test Timeout      2 hour
# #Library           taf.transport.ssh    WITH NAME    csn
# Library           ${CURDIR}/../libraries/get_bts_info.py
# Resource          ${CURDIR}/../common/coam_resource.robot
# Library           OperatingSystem
# 
# Documentation
# ...    author: zora.zhang
# ...    contact: zora.zhang@nokia-sbell.com
# ...    squad group: SG_05
# ...    Feature 5GC001213 in 5G19A program
# 
# Force Tags    CA_5G_OAM      #CLOUD_5G_RPI_SB_ASIKA101L_ABILA101B1_AEUA_18A  #4.835
# ...    PY36
# 
# *** Variables ***
# ${WEBUI_URL}      https://${asik_addr}/
# ${ipsec_commission_file}        /home/nokia/commission/Configuration_scf_MRBTS-2265_Ipv6_2tunnel.xml
# ${vm_path}                /home/nokia/
# ${create_backup_dir}      backupscf/
# ${gnb_addr}              ${asik_addr}
# ${gnb_X2Cplane}          2a00:8a00:8000:136:10:57:227:e5
# ${gnb_S1Uplane}          2a00:8a00:8000:136:10:57:249:92
# ${switch_7750_subnet1_ip}         2a00:8a00:8000:136:10:57:248:72
# ${switch_7750_subnet2_ip}         2a00:8a00:8000:136:10:57:248:71
# 
# *** Test Cases ***
# [1]5GC001545-YA_5GC001213_05_Basic_U_C_M_planes_mapping_to_different_VLANs_with_IPV4_tunnel
#     [Documentation]
#     ...    *****************
#     ...    - [TEST PURPOSE] To verify gNB IPSec shall keep IPSec configuration persistent
#     ...    ******************
#     ...    History of changes
#     ...    ******************
#     ...    - 06.05.2019   https://jiradc.int.net.nokia.com/browse/WESTLAKE-1055    - Created
#     [Tags]    Owner_zora.zhang@nokia-sbell.com    CIT_22R1    CRT_22R3
#     Step1: Login BTS via WebUI and check HW state
#     #Step2: Backup commission file via WebUI
#     #Step3: Import ipsec commission file
#     #Step4: Login and check HW state with ipsec commission file
#     #Step5: Check certificate via WebUI
#     Step6: Check ipsec tunnel connection is up
#     Step7: Make traffic from leftsubnet to rightsubnet
# 
# *** Keywords ***
# Teardown
#    #Step8: Recover environment with backup commission file
#    selenium_coam.logout
#    selenium_coam.disable_virtual_display
# 
# Step1: Login BTS via WebUI and check HW state
#     log to console    Step1: Login BTS via WebUI and check HW state
#     selenium_coam.login    ${WEBUI_URL}    ${WEBUI_USER}    ${WEBUI_PASSWORD}
#     sleep    3s
#     wait until keyword succeeds    5min    30s    Check ABIL is UP
#     #wait until keyword succeeds    5min    30s    Check ASIK is UP
#     sleep    3s
# 
# Step2: Backup commission file via WebUI
#     log to console    Step2: Backup commission file via WebUI
#     ${commission_file}     selenium_coam.backup_bts_site_configuration
#     sleep    10s
#     csn.connect to    ${host_addr}    ${host_username}    ${host_password}    alias=VM
#     csn.send_command    command=cd ${vm_path};mkdir ${create_backup_dir}    connection=VM
#     set suite variable    ${backup_scf_path}    ${vm_path}${create_backup_dir}
#     run process    scp -r ${commission_file} ${backup_scf_path}    shell=yes
#     csn.send_command    command=cd ${backup_scf_path};ls    connection=VM
#     ${backup_scf_file_1}    csn.read output    connection=VM
#     @{backup_scf_list}    Split Command Line    ${backup_scf_file_1}
#     set suite variable    ${backup_scf_file}    @{backup_scf_list}[0]
#     csn.disconnect    connection=VM
#     sleep    3s
#     Confirm backup scf file
# 
# Step3: Import ipsec commission file
#     log to console    Step3: Import ipsec commission file
#     selenium_coam.load_commissioning_file_and_check_load_status   file_path=${ipsec_commission_file}
#     sleep    3s
#     selenium_coam.validate_plan
#     sleep    3s
#     selenium_coam.activate_plan    activate_plan_despite_errors=True
#     sleep    3s
#     selenium_coam.check_activate_plan_status
#     run keyword and ignore error    selenium_coam.logout
# 
#    # wait until keyword succeeds    3min    30s    Check BTS is lost
# 
# Step4: Login and check HW state with ipsec commission file
#     log to console    Step4: Login and check HW state with ipsec commission file
#     Check ABIL is UP
#     Check ASIK is UP
#     sleep    3s
# 
# Step5: Check certificate via WebUI
#     log to console    Step5: Check certificate via WebUI
#     #lack of KW
# 
# Step6: Check ipsec tunnel connection is up
#     log to console    Step6: Check ipsec tunnel connection is up
#     Check ipsec tunnel is up
# 
# Step7: Make traffic from leftsubnet to rightsubnet
#     log to console    Step7: Make traffic from leftsubnet to rightsubnet
#     Ping gnb subnet to 7750 subnet success
# 
# Step8: Recover environment with backup commission file
#     log to console    Step8: Recover environment with backup commission file
#     wait until keyword succeeds    5min    30s   selenium_coam.login    ${WEBUI_URL}    ${WEBUI_USER}    ${WEBUI_PASSWORD}
#     Import previous backup commission file
#     Check ABIL is UP
#     Check ASIK is UP
#     sleep    3s
#     Delete backup commission file
# 
# Delete backup commission file
#     csn.connect to    ${host_addr}    ${host_username}    ${host_password}    alias=VM
#     csn.send_command    command=cd ${vm_path};rm -rf ${create_backup_dir}    connection=VM
#     csn.disconnect    connection=VM
# 
# Import previous backup commission file
#     selenium_coam.load_commissioning_file_and_check_load_status    file_path=${backup_scf_path_file}
#     sleep   3s
#     selenium_coam.validate_plan
#     sleep    3s
#     selenium_coam.activate_plan    activate_plan_despite_errors=True
#     sleep    3s
#     selenium_coam.check_activate_plan_status
# 
# Confirm backup scf file
#     csn.connect to    ${host_addr}    ${host_username}    ${host_password}    alias=VM
#     Directory Should Exist    ${backup_scf_path}
#     List Files In Directory    ${backup_scf_path}
#     ${backup_scf_path_file}    join path    ${backup_scf_path}    ${backup_scf_file}
#     File Should Exist    ${backup_scf_path_file}
#     set suite variable    ${backup_scf_path_file}
#     csn.disconnect    connection=VM
# 
# Check ipsec tunnel is up
#     csn.connect to    ${asik_addr}    ${asik_username}    ${asik_password}    alias=gNB
# 	sleep    5s
#     #csn.send_command    command=ipsec restart    connection=gNB
#     sleep    10s
#     csn.send_command    command=ipsec statusall    connection=gNB
#     sleep    10s
#     ${ipsec_status_info}    csn.read output    connection=gNB
# 
#     should match regexp     ${ipsec_status_info}    conn9\[[0-9]*\]: ESTABLISHED
#     should match regexp     ${ipsec_status_info}    conn9\[[0-9]*\]: IKE proposal: AES_CBC_128
#     should match regexp     ${ipsec_status_info}    conn9\{[0-9]*\}:  AES_CBC_128
# 
#     should match regexp     ${ipsec_status_info}    conn1\[[0-9]*\]: ESTABLISHED
#     should match regexp     ${ipsec_status_info}    conn1\[[0-9]*\]: IKE proposal: AES_CBC_128
#     should match regexp     ${ipsec_status_info}    conn1\{[0-9]*\}:  AES_CBC_128
#     csn.disconnect    connection=gNB
# 
# Ping gnb subnet to 7750 subnet success
#     csn.connect to    ${asik_addr}    ${asik_username}    ${asik_password}    alias=gNB
#     #csn.send_command    command=ipsec restart    connection=gNB
#     sleep    10s
# 
#     csn.send_command    command=ping -I ${gnb_S1Uplane} ${switch_7750_subnet2_ip} -c 5    connection=gNB
#     sleep    3s
#     ${ipsec_ping_info}    csn.read output    connection=gNB
#     should contain    ${ipsec_ping_info}
#     ...    PING 2a00:8a00:8000:136:10:57:248:71(2a00:8a00:8000:136:10:57:248:71) from 2a00:8a00:8000:136:10:57:249:92
#     should contain    ${ipsec_ping_info}    64 bytes from 2a00:8a00:8000:136:10:57:248:71: icmp_seq
# 
#     #csn.send_command    command=ping -I ${gnb_X2Cplane} ${switch_7750_subnet1_ip} -c 5    connection=gNB
#     #sleep    3s
#     #${ipsec_ping_info}    csn.read output    connection=gNB
#     #should contain    ${ipsec_ping_info}
#     #...    PING 2a00:8a00:8000:136:10:57:248:72(2a00:8a00:8000:136:10:57:248:72) from 2a00:8a00:8000:136:10:57:227:e5
#     #should contain    ${ipsec_ping_info}    64 bytes from 2a00:8a00:8000:136:10:57:248:72: icmp_seq
# 
#     csn.disconnect    connection=gNB
