*** Settings ***
Documentation
...   author: zora.zhang
...   contact: zora.zhang@nokia-sbell.com

#Library           taf.transport.ssh    WITH NAME    csn
Library           ../../libraries/get_bts_info.py
Library           OperatingSystem
Library           Process
Library           Collections
Library           DateTime
Library           String

Resource          ../../common/coam_resource.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variables ***
${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
${WEBUI_URL}                https://${asik_addr}/
${ipsec_commission_file}    /home/ute/commission/scf_MRBTS-2257.xml
${vm_path}                  /home/ute/
${create_backup_dir}        backupscf/
${Strongswan_addr}          10.57.167.5
${Strongswan_USER}          root
${Stswan_PASSWORD}          nokia123
${gnb_S1Uplane}             ${tl.gnbs[0].cu.s1u.v4}
${gnb_X2Cplane}             ${tl.gnbs[0].cu.x2c.v4}
${gnb_Mplane}               ${tl.gnbs[0].cu.f1m.v4}
${gnb_X2Uplane}             ${tl.gnbs[0].cu.x2u.v4}
${gnb_X2Cplane_subnet}      ${tl.gnbs[0].cu.tracing.v4}
${switch_subnet1}           10.57.143.159
${gnb_S1Uplanev6}           ${tl.gnbs[0].cu.s1u.v6}
${gnb_X2Cplanev6}           ${tl.gnbs[0].cu.x2c.v6}
${gnb_Mplanev6}             ${tl.gnbs[0].cu.f1m.v6}
${gnb_X2Uplanev6}           ${tl.gnbs[0].cu.x2u.v6}
${gnb_X2Uplanev6_2}         ${tl.gnbs[0].cu.tracing.v6}
${switch_subnet1v6}         2a00:8a00:8000:136:10:57:143:159
${switch_subnet2v6}         2a00:8a00:8000:136:10:57:245:1
${7750_switch_interface}    10.57.143.157
${7750_switch_interface_v6}    2a00:8a00:8000:136:10:57:143:157
${enb_ip}                   ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}

*** Keywords ***

Import ipsec commission file
    Login BTS via WebUI and check HW state
    Backup commission file via WebUI
    Add commission file
    Check HW state with ipsec commission file

Login BTS via WebUI and check HW state
    log to console    Login BTS via WebUI and check HW state
    wait until keyword succeeds    10min    1min    WEBUI Login
    selenium_coam.disable_screen_lock

Add commission file
    log to console    Add commission file
    sleep    2s
    run keyword and ignore error    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${ipsec_commission_file}
    sleep    3s
    Validate and activate and check activate plan status
    sleep    10min

Check HW state with ipsec commission file
    log to console    Check HW state with ipsec commission file
    wait until keyword succeeds    10min    1min    Check SMOD status with command
    sleep    3s

Delete backup commission file
    csn.connect to    hostname=${host_addr}    username=${host_username}    password=${host_password}    alias=VM
    csn.send_command    command=cd ${vm_path};rm -rf ${create_backup_dir}    connection=VM
    csn.disconnect    connection=VM

Import previous backup commission file
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${backup_scf_path_file}
    sleep   3s
    Validate and activate and check activate plan status
    sleep    3s
    run keyword and ignore error    selenium_coam.logout
    sleep   2min

Check ipsec tunnel is down
    csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gNB
    sleep    3s
    csn.send_command    command=ipsec statusall    connection=gNB
    sleep    5s
    ${ipsec_fail_statu}    csn.read output    connection=gNB
    should be empty    ${ipsec_fail_statu}
    Run Keyword And Ignore Error    csn.disconnect    connection=gNB

Check SMOD status with command
    csn.connect_to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gNB
    sleep    5s
    csn.send_command    command=export PYTHONPATH=/opt/hwmt/python;python3 /opt/hwmt/python/hwapi/AdetS.py -s -n 0x2011    connection=gNB
    sleep    15s
    ${output1}    csn.read output    connection=gNB
    Should Match Regexp    ${output1}    0x20.*FSM2_FCT.*ready
    Should Match Regexp    ${output1}    0x22.*FSM2_FSP1.*ready
    Run Keyword And Ignore Error    csn.disconnect    connection=gNB

###step level kw###
Teardown
   #"${Step}": Recover environment with backup commission file
   selenium_coam.logout
   selenium_coam.disable_virtual_display

"${Step}": Login BTS via WebUI and check HW state
    log to console    "${Step}": Login BTS via WebUI and check HW state
    selenium_coam.login    ${WEBUI_URL}    ${WEBUI_USER}    ${WEBUI_PASSWORD}
    sleep    3s
    wait until keyword succeeds    5min    30s    Check ABIL is UP
    wait until keyword succeeds    5min    30s    Check ASIK is UP
    sleep    3s

"${Step}": Backup commission file via WebUI
    log to console    "${Step}": Backup commission file via WebUI
    ${commission_file}    selenium_coam.backup_bts_site_configuration
    sleep    10s
    csn.connect to    hostname=${host_addr}    username=${host_username}    password=${host_password}    alias=VM
    csn.send_command    command=cd ${vm_path};mkdir ${create_backup_dir}    connection=VM
    set suite variable    ${backup_scf_path}    ${vm_path}${create_backup_dir}
    run process    scp -r ${commission_file} ${backup_scf_path}    shell=yes
    csn.send_command    command=cd ${backup_scf_path};ls    connection=VM
    ${backup_scf_file_1}    csn.read output    connection=VM
    @{backup_scf_list}    Split Command Line    ${backup_scf_file_1}
    set suite variable    ${backup_scf_file}    ${backup_scf_list}[0]
    csn.disconnect    connection=VM
    sleep    3s
    Confirm backup scf file

"${Step}": Import ipsec commission file
    log to console    "${Step}": Import ipsec commission file
    selenium_coam.load_commissioning_file_and_check_load_status   file_path=${ipsec_commission_file}
    sleep    3s
    selenium_coam.validate_plan
    sleep    3s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    3s
    selenium_coam.check_activate_plan_status
    run keyword and ignore error    selenium_coam.logout
    #sleep    3min

   # wait until keyword succeeds    3min    30s    Check BTS is lost

"${Step}": Login and check HW state with ipsec commission file
    log to console    "${Step}": Login and check HW state with ipsec commission file
    wait until keyword succeeds    30min    1min    Check ABIL is UP
    wait until keyword succeeds    30min    1min     Check ASIK is UP
    sleep    3s

"${Step}": Check ipsec tunnel connection is up for 003
    log to console    "${Step}": Check ipsec tunnel connection is up
    Check ipsec tunnel is up for 003

"${Step}": Make traffic from leftsubnet to rightsubnet for 003
    log to console    "${Step}": Make traffic from leftsubnet to rightsubnet
    Ping gnb subnet to 7750 subnet success for 003

"${Step}": Recover environment with backup commission file
    log to console    "${Step}": Recover environment with backup commission file
    wait until keyword succeeds    5min    30s   selenium_coam.login    url=${WEBUI_URL}    username=${WEBUI_USER}    password=${WEBUI_PASSWORD}
    Import previous backup commission file
    wait until keyword succeeds    30min    1min    Check ABIL is UP
    wait until keyword succeeds    30min    1min    Check ASIK is UP
    sleep    3s
    Delete backup commission file

Confirm backup scf file
    csn.connect to    hostname=${host_addr}    username=${host_username}    password=${host_password}    alias=VM
    Directory Should Exist    ${backup_scf_path}
    List Files In Directory    ${backup_scf_path}
    ${backup_scf_path_file}    join path    ${backup_scf_path}    ${backup_scf_file}
    File Should Exist    ${backup_scf_path_file}
    set suite variable    ${backup_scf_path_file}
    csn.disconnect    connection=VM

Check ipsec tunnel is up for 003
    csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gNB
    sleep    5s
    #csn.send_command    command=ipsec restart    connection=gNB
    sleep    10s
    csn.send_command    command=ipsec statusall    connection=gNB
    sleep    10s

    ${ipsec_status_info}    csn.read output    connection=gNB
    #should contain    ${ipsec_status_info}    Security Associations (3 up, 0 connecting):
    should match regexp    ${ipsec_status_info}    conn4\[[0-9]*\]: ESTABLISHED
    should match regexp    ${ipsec_status_info}    conn4\[[0-9]*\]: IKE proposal: 3DES_CBC
    should match regexp    ${ipsec_status_info}    conn4\{[0-9]*\}:  3DES_CBC

    should match regexp    ${ipsec_status_info}    conn3\[[0-9]*\]: ESTABLISHED
    should match regexp    ${ipsec_status_info}    conn3\[[0-9]*\]: IKE proposal: AES_CBC_128
    should match regexp    ${ipsec_status_info}    conn3\{[0-9]*\}:  AES_CBC_128

    csn.disconnect    connection=gNB

Ping gnb subnet to 7750 subnet success for 003
    csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gNB
    #csn.send_command    command=ipsec restart    connection=gNB
    sleep    10s

    csn.send_command    command=ping -I ${gnb_X2Cplane} ${switch_subnet1} -c 5    connection=gNB
    sleep    3s
    ${ipsec_ping_info}    csn.read output     connection=gNB
    should contain    ${ipsec_ping_info}    PING ${switch_subnet1} (${switch_subnet1}) from ${gnb_X2Cplane}
    should contain    ${ipsec_ping_info}    64 bytes from ${switch_subnet1}: icmp_seq

    csn.send_command    command=ping -I ${gnb_Mplane} ${switch_subnet1} -c 5    connection=gNB
    sleep    3s
    ${ipsec_ping_info}    csn.read output     connection=gNB
    should contain    ${ipsec_ping_info}    PING ${switch_subnet1} (${switch_subnet1}) from ${gnb_Mplane}
    should contain    ${ipsec_ping_info}    64 bytes from ${switch_subnet1}: icmp_seq

    csn.disconnect    connection=gNB
####

"${Step}": Check certificate via WebUI
    log to console    "${Step}": Check certificate via WebUI
    #lack of KW

"${Step}": Check ipsec tunnel connection is up for 004
    log to console    "${Step}": Check ipsec tunnel connection is up
    Check ipsec tunnel is up for 004

"${Step}": Make traffic from leftsubnet to rightsubnet for 004
    log to console    "${Step}": Make traffic from leftsubnet to rightsubnet
    Ping gnb subnet to 7750 subnet success for 004

Check ipsec tunnel is up for 004
    csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gNB
    sleep    5s
    #csn.send_command    command=ipsec restart    connection=gNB
    sleep    10s
    csn.send_command    command=ipsec statusall    connection=gNB
    sleep    10s
    ${ipsec_status_info}    csn.read output    connection=gNB

    should match regexp     ${ipsec_status_info}    conn9\[[0-9]*\]: ESTABLISHED
    should match regexp     ${ipsec_status_info}    conn9\[[0-9]*\]: IKE proposal: AES_CBC_128
    should match regexp     ${ipsec_status_info}    conn9\{[0-9]*\}:  AES_CBC_128

    should match regexp     ${ipsec_status_info}    conn7\[[0-9]*\]: ESTABLISHED
    should match regexp     ${ipsec_status_info}    conn7\[[0-9]*\]: IKE proposal: 3DES_CBC
    should match regexp     ${ipsec_status_info}    conn7\{[0-9]*\}:  3DES_CBC

    csn.disconnect    connection=gNB

Ping gnb subnet to 7750 subnet success for 004
    csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gNB
    #csn.send_command    command=ipsec restart    connection=gNB
    sleep    10s

    csn.send_command    command=ping -I ${gnb_S1Uplanev6} ${switch_subnet2v6} -c 5    connection=gNB
    sleep    3s
    ${ipsec_ping_info}    csn.read output    connection=gNB
    should contain    ${ipsec_ping_info}    PING ${switch_subnet2v6}(${switch_subnet2v6}) from ${gnb_S1Uplanev6}
    should contain    ${ipsec_ping_info}    64 bytes from ${switch_subnet2v6}: icmp_seq

    csn.send_command    command=ping -I ${gnb_Mplanev6} ${switch_subnet1v6} -c 5    connection=gNB
    sleep    3s
    ${ipsec_ping_info}    csn.read output    connection=gNB
    should contain    ${ipsec_ping_info}    PING ${switch_subnet1v6}(${switch_subnet1v6}) from ${gnb_Mplanev6}
    should contain    ${ipsec_ping_info}    64 bytes from ${switch_subnet1v6}: icmp_seq

    csn.disconnect    connection=gNB
####
"${Step}": Check ipsec tunnel connection is up for 005
    log to console    "${Step}": Check ipsec tunnel connection is up
    Check ipsec tunnel is up for 005

"${Step}": Make traffic from leftsubnet to rightsubnet for 005
    log to console    "${Step}": Make traffic from leftsubnet to rightsubnet
    Ping gnb subnet to 7750 subnet success for 005

Check ipsec tunnel is up for 005
    csn.connect to    hostname=${Strongswan_addr}    username=${Strongswan_USER}    password=${Stswan_PASSWORD}    alias=VM
    sleep    3s
    #csn.send_command    command=ipsec restart    connection=VM
    sleep    3s
    csn.disconnect    connection=VM
    sleep    3s
    csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gNB
    sleep    5s
    #csn.send_command    command=ipsec restart    connection=gNB
    sleep    20s
    csn.send_command    command=ipsec statusall    connection=gNB
    sleep    10s

    ${ipsec_status_info}    csn.read output    connection=gNB
    #should contain    ${ipsec_status_info}    Security Associations (3 up, 0 connecting):
    should match regexp    ${ipsec_status_info}    conn4\[[0-9]*\]: ESTABLISHED
    should match regexp    ${ipsec_status_info}    conn4\[[0-9]*\]: IKE proposal: 3DES_CBC
    should match regexp    ${ipsec_status_info}    conn4\{[0-9]*\}:  3DES_CBC

    should match regexp    ${ipsec_status_info}    conn3\[[0-9]*\]: ESTABLISHED
    should match regexp    ${ipsec_status_info}    conn3\[[0-9]*\]: IKE proposal: AES_CBC_128
    should match regexp    ${ipsec_status_info}    conn3\{[0-9]*\}:  AES_CBC_128

    should match regexp    ${ipsec_status_info}    conn2\[[0-9]*\]: ESTABLISHED
    should match regexp    ${ipsec_status_info}    conn2\[[0-9]*\]: IKE proposal: AES_CBC_128
    should match regexp    ${ipsec_status_info}    conn2\{[0-9]*\}:  AES_CBC_128

    csn.disconnect    connection=gNB

Ping gnb subnet to 7750 subnet success for 005
    csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gNB
    #csn.send_command    command=ipsec restart    connection=gNB
    sleep    10s
    csn.send_command    command=ping ${Strongswan_addr} -c 5    connection=gNB
    #csn.send_command    command=ping -I ${gnb_S1Uplane} ${Strongswan_addr} -c 5    connection=gNB
    sleep    3s
    ${ipsec_ping_info}    csn.read output     connection=gNB
    should contain    ${ipsec_ping_info}    PING ${Strongswan_addr} (${Strongswan_addr})
    #should contain    ${ipsec_ping_info}    PING ${Strongswan_addr} (${Strongswan_addr}) from ${gnb_S1Uplane}
    should contain    ${ipsec_ping_info}    64 bytes from ${Strongswan_addr}: icmp_seq

    csn.send_command    command=ping -I ${gnb_X2Cplane} ${switch_subnet1} -c 5    connection=gNB
    sleep    3s
    ${ipsec_ping_info}    csn.read output     connection=gNB
    should contain    ${ipsec_ping_info}    PING ${switch_subnet1} (${switch_subnet1}) from ${gnb_X2Cplane}
    should contain    ${ipsec_ping_info}    64 bytes from ${switch_subnet1}: icmp_seq

    csn.send_command    command=ping -I ${gnb_Mplane} ${switch_subnet1} -c 5    connection=gNB
    sleep    3s
    ${ipsec_ping_info}    csn.read output     connection=gNB
    should contain    ${ipsec_ping_info}    PING ${switch_subnet1} (${switch_subnet1}) from ${gnb_Mplane}
    should contain    ${ipsec_ping_info}    64 bytes from ${switch_subnet1}: icmp_seq

    csn.disconnect    connection=gNB
####
"${Step}": Check ipsec tunnel connection is up for 006
    log to console    "${Step}": Check ipsec tunnel connection is up
    Check ipsec tunnel is up for 006

"${Step}": Make traffic from leftsubnet to rightsubnet for 006
    log to console    "${Step}": Make traffic from leftsubnet to rightsubnet
    Ping gnb subnet to 7750 subnet success for 006

Check ipsec tunnel is up for 006
    csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gNB
    sleep    5s
    #csn.send_command    command=ipsec restart    connection=gNB
    sleep    10s
    csn.send_command    command=ipsec statusall    connection=gNB
    sleep    10s
    ${ipsec_status_info}    csn.read output    connection=gNB

    should match regexp     ${ipsec_status_info}    conn9\[[0-9]*\]: ESTABLISHED
    should match regexp     ${ipsec_status_info}    conn9\[[0-9]*\]: IKE proposal: AES_CBC_128
    should match regexp     ${ipsec_status_info}    conn9\{[0-9]*\}:  AES_CBC_128

    should match regexp     ${ipsec_status_info}    conn7\[[0-9]*\]: ESTABLISHED
    should match regexp     ${ipsec_status_info}    conn7\[[0-9]*\]: IKE proposal: 3DES_CBC
    should match regexp     ${ipsec_status_info}    conn7\{[0-9]*\}:  3DES_CBC

    should match regexp     ${ipsec_status_info}    conn1\[[0-9]*\]: ESTABLISHED
    should match regexp     ${ipsec_status_info}    conn1\[[0-9]*\]: IKE proposal: AES_CBC_128
    should match regexp     ${ipsec_status_info}    conn1\{[0-9]*\}:  AES_CBC_128
    csn.disconnect    connection=gNB

Ping gnb subnet to 7750 subnet success for 006
    csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gNB
    #csn.send_command    command=ipsec restart    connection=gNB
    sleep    10s

    csn.send_command    command=ping -I ${gnb_S1Uplanev6} ${switch_subnet2v6} -c 5    connection=gNB
    sleep    3s
    ${ipsec_ping_info}    csn.read output    connection=gNB
    should contain    ${ipsec_ping_info}    PING ${switch_subnet2v6}(${switch_subnet2v6}) from ${gnb_S1Uplanev6}
    should contain    ${ipsec_ping_info}    64 bytes from ${switch_subnet2v6}: icmp_seq

    csn.send_command    command=ping -I ${gnb_Mplanev6} ${switch_subnet1v6} -c 5    connection=gNB
    sleep    3s
    ${ipsec_ping_info}    csn.read output    connection=gNB
    should contain    ${ipsec_ping_info}    PING ${switch_subnet1v6}(${switch_subnet1v6}) from ${gnb_Mplanev6}
    should contain    ${ipsec_ping_info}    64 bytes from ${switch_subnet1v6}: icmp_seq

    csn.send_command    command=ping -I ${gnb_X2Uplanev6} ${switch_subnet1v6} -c 5    connection=gNB
    sleep    3s
    ${ipsec_ping_info}    csn.read output    connection=gNB
    should contain    ${ipsec_ping_info}    PING ${switch_subnet1v6}(${switch_subnet1v6}) from ${gnb_X2Uplanev6}
    should contain    ${ipsec_ping_info}    64 bytes from ${switch_subnet1v6}: icmp_seq
    csn.disconnect    connection=gNB
