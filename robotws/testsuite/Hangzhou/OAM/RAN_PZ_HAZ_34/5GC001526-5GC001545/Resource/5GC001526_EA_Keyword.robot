*** Settings ***
Documentation
...   author: wei.2.duan
...   contact: wei.2.duan@nokia-sbell.com

#Library           taf.transport.ssh    WITH NAME    csn
Library           ../../libraries/get_bts_info.py
Resource          ../../common/coam_resource.robot
Library           OperatingSystem
Library           Process
Library           Collections
Library           DateTime
Library           String


*** Variables ***
${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
${WEBUI_URL}                https://${asik_addr}/
${ipsec_commission_file}    /home/ute/commission/scf_MRBTS-2257.xml
${vm_path}                  /home/ute/
${create_backup_dir}        backupscf/
${Strongswan_addr}         10.57.167.5
${Strongswan_USER}         root
${Stswan_PASSWORD}         nokia123
${gnb_S1Uplane}            ${tl.gnbs[0].cu.s1u.v4}
${gnb_X2Cplane}            ${tl.gnbs[0].cu.x2c.v4}
${gnb_Mplane}              ${tl.gnbs[0].cu.f1m.v4}
${gnb_X2Uplane}            ${tl.gnbs[0].cu.x2u.v4}
${gnb_X2Cplane_subnet}     ${tl.gnbs[0].cu.tracing.v4}
${switch_subnet1}          10.57.143.159
${switch_subnet2}          10.57.245.1
${switch_subnet3}          10.57.248.112
${gnb_S1Uplanev6}          ${tl.gnbs[0].cu.s1u.v6}
${gnb_X2Cplanev6}          ${tl.gnbs[0].cu.x2c.v6}
${gnb_Mplanev6}            ${tl.gnbs[0].cu.f1m.v6}
${gnb_X2Uplanev6}          ${tl.gnbs[0].cu.x2u.v6}
${gnb_X2Uplanev6_2}        ${tl.gnbs[0].cu.tracing.v6}
${switch_subnet1v6}        2a00:8a00:8000:136:10:57:143:159
${switch_subnet2v6}        2a00:8a00:8000:136:10:57:245:1
${7750_switch_interface}    10.57.143.157
${7750_switch_interface_v6}    2a00:8a00:8000:136:10:57:143:157
${enb_ip}

*** Keywords ***

Import ipsec commission file
    Login BTS via WebUI and check HW state
    #Backup commission file via WebUI
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
    Validate and activate and check activate plan status for IPSEC
    sleep    15min

Check HW state with ipsec commission file
    log to console    Check HW state with ipsec commission file
    wait until keyword succeeds    10min    1min    Check left gnb status with command
    sleep    3s

Delete backup commission file
    csn.connect to    hostname=${host_addr}    username=${host_username}    password=${host_password}    alias=VM
    csn.send_command    command=cd ${vm_path};rm -rf ${create_backup_dir}    connection=VM
    csn.disconnect    connection=VM

Import previous backup commission file
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${backup_scf_path_file}
    sleep   3s
    Validate and activate and check activate plan status for IPSEC
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

Check left gnb status with command
    csn.connect_to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gNB
    sleep    5s
    csn.send_command    command=export PYTHONPATH=/opt/hwmt/python;python3 /opt/hwmt/python/hwapi/AdetS.py -s -n 0x2011   connection=gNB
    sleep    15s
    ${output1}    csn.read output    connection=gNB
    Should Match Regexp    ${output1}    0x20.*FSM2_FCT.*ready
    Should Match Regexp    ${output1}    0x22.*FSM2_FSP1.*ready
    Run Keyword And Ignore Error    csn.disconnect    connection=gNB

Validate and activate and check activate plan status for IPSEC
    selenium_coam.validate_plan
    sleep    3s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    3s

###step level kw###
Teardown
    Run Keyword And Ignore Error    selenium_coam.disable_virtual_display

"${Step}": Check ipsec tunnel connection is up
    log to console    "${Step}": Check ipsec tunnel connection is up
    wait until keyword succeeds    10min    1min    Check left gnb status with command
    ${result_1}    Run Keyword And Ignore Error    Check ipsec tunnel is up
    ${result_2}    Run Keyword And Ignore Error    Check ipsec conf exist
    Run Keyword If     "${result_1[0]}" == "FAIL" or "${result_2[0]}" == "FAIL"    Run Keywords
    ...    Import ipsec commission file    AND    Check ipsec tunnel is up
    sleep    3s

"${Step}": Make traffic from leftsubnet to rightsubnet
    log to console    "${Step}": Make traffic from leftsubnet to rightsubnet
    Ping gnb subnet to 7750 subnet








