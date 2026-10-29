*** Settings ***
Documentation
...   author: annie.hu
...   contact: annie.hu@nokia-sbell.com

Library           taf.transport.ssh    WITH NAME    csn
Library           ../../libraries/get_bts_info.py
Resource          ../../common/coam_resource.robot
#Library           OperatingSystem
#Library           Process
#Library           Collections
#Library           DateTime
#Library           String


*** Variables ***
#${asik_addr}                 10.57.235.235
#${asik_username}             toor4nsn
#${asik_password}             oZPS0POrRieRtu
#${MRBTS_ID}                 1970
#${WEBUI_URL}                https://${asik_addr}/
${ipsec_commission_file}    /home/ute/commission/scf_MRBTS-1970.xml
${vm_path}                  /home/ute/
${create_backup_dir}        backupscf/
${Strongswan_addr}         10.57.167.5
${Strongswan_USER}         root
${Stswan_PASSWORD}         nokia123

${gnb_Mplane}              ${tl.gnbs[0].cu.f1m.v4}
${gnb_ngCplane}            ${tl.gnbs[0].cu.ngc.v4}
${gnb_ngUplane}            ${tl.gnbs[0].cu.ngu.v4}
${gnb_xnCplane}            ${tl.gnbs[0].cu.xnc.v4}
${gnb_xnUplane}            ${tl.gnbs[0].cu.xnu.v4}
${gnb_xnUplane_subnet}     ${tl.gnbs[0].cu.tracing.v4}
${gnb_S1Uplane}            ${tl.gnbs[0].cu.s1u.v4}
#${gnb_X2Cplane}            ${tl.gnbs[0].cu.x2c.v4}
#${gnb_X2Uplane}            ${tl.gnbs[0].cu.x2u.v4}
${gnb_Mplanev6}            ${tl.gnbs[0].cu.f1m.v6}
${gnb_ngCplanev6}          ${tl.gnbs[0].cu.ngc.v6}
${gnb_ngUplanev6}          ${tl.gnbs[0].cu.ngu.v6}
${gnb_xnCplanev6}          ${tl.gnbs[0].cu.xnc.v6}
${gnb_xnUplanev6}          ${tl.gnbs[0].cu.xnu.v6}
${gnb_xnUplane_subnetv6}   ${tl.gnbs[0].cu.tracing.v6}
#${gnb_S1Uplanev6}          ${tl.gnbs[0].cu.s1u.v6}
#${gnb_X2Cplanev6}          ${tl.gnbs[0].cu.x2c.v6}
#${gnb_X2Uplanev6}          ${tl.gnbs[0].cu.x2u.v6}
#${gnb_X2Uplanev6_2}        ${tl.gnbs[0].cu.tracing.v6}
${switch_subnet1}          10.57.249.1
${switch_subnet1v6}        2a00:8a00:8000:136:10:57:249:1
${7750_switch_ipv4}        10.57.143.157
${7750_switch_ipv6}        2a00:8a00:8000:136:10:57:143:157
${peer_addr}                10.57.227.229
${peer_gnb_subnet}         10.57.249.146


#${gnb_Mplane}              10.57.247.162
#${gnb_ngCplane}            10.57.247.166
#${gnb_ngUplane}            10.57.247.170
#${gnb_xnCplane}            10.57.247.174
#${gnb_xnUplane}            10.57.152.34
#${gnb_xnUplane_subnet}     10.57.152.35
#${gnb_Mplanev6}            2a00:8a00:8000:136:10:57:247:a2
#${gnb_ngCplanev6}          2a00:8a00:8000:136:10:57:247:a6
#${gnb_ngUplanev6}          2a00:8a00:8000:136:10:57:247:aa
#${gnb_xnCplanev6}          2a00:8a00:8000:136:10:57:247:ae
#${gnb_xnUplanev6}          2a00:8a00:8000:136:10:57:152:22
#${gnb_xnUplane_subnetv6}   2a00:8a00:8000:136:10:57:152:23
#${switch_subnet1}          10.57.249.1

#${gnb_Mplane}             10.57.227.235
#${gnb_ngCplane}            10.57.249.126
#${gnb_ngUplane}            10.57.249.130
#${gnb_xnCplane}            10.57.249.134
#${gnb_xnUplane}            10.57.152.170
#${gnb_xnUplane_subnet}     10.57.152.171
#${gnb_Mplanev6}            2a00:8a00:8000:136:10:57:227:e2
#${gnb_ngCplanev6}          2a00:8a00:8000:136:10:57:249:7e
#${gnb_ngUplanev6}          2a00:8a00:8000:136:10:57:249:82
#${gnb_xnCplanev6}          2a00:8a00:8000:136:10:57:249:86
#${gnb_xnUplanev6}          2a00:8a00:8000:136:10:57:152:aa
#${gnb_xnUplane_subnetv6}   2a00:8a00:8000:136:10:57:152:ab
#${switch_subnet1}          10.57.248.1


*** Keywords ***

Case setup
    [Documentation]   This keyword defines case steup with multiple conditions
    cOAM Common Test Setup
    WEBUI Login
    Get MRBTS Id

Get MRBTS Id
    [Documentation]   This keyword used to get MRBTS-XXX online
    log to console    Get MRBTS Id online
	${MRBTS_ID}    Wait Until Keyword Succeeds    2min    10s    selenium_coam.get_bts_id
    #${mrbts_id}=    Set Variable    MRBTS-${mrbtsId}
    set suite variable    ${MRBTS_ID}
    sleep    2s
	
Import ipsec commission file
    [Documentation]   This keyword used to import scf ad check status after that
    Login BTS via WebUI and check HW state
    #Backup commission file via WebUI
    Add commission file
    Check HW state with ipsec commission file

Login BTS via WebUI and check HW state
    [Documentation]   This keyword used to login webui
    log to console    Login BTS via WebUI and check HW state
	sleep    12min
    wait until keyword succeeds    10min    1min    WEBUI Login    #${virtual_enable}=${false}
    selenium_coam.disable_screen_lock

Add commission file
    [Documentation]   This keyword used to add commission file to gNB and activate
    log to console    Add commission file
    sleep    3s
    run keyword and ignore error    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${ipsec_commission_file}
    sleep    3s
    Validate and activate and check activate plan status for ipsec
    sleep    5min

Check HW state with ipsec commission file
    [Documentation]   This keyword checks gnb status with command
    log to console    Check HW state with ipsec commission file
    wait until keyword succeeds    10min    1min    Check left gnb status with command
    sleep    3s

Delete backup commission file
    [Documentation]   This keyword used to delete backup files so that to restore TA ENV
    csn.connect to    hostname=${host_addr}     username=${host_username}     password=${host_password}    alias=VM
    csn.send_command    command=cd ${vm_path};rm -rf ${create_backup_dir}    connection=VM
    csn.disconnect    connection=VM

Import previous backup commission file
    [Documentation]   This keyword used to recover env with original backup scf
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${backup_scf_path_file}
    sleep   3s
    Validate and activate and check activate plan status for ipsec
    sleep    3s
    run keyword and ignore error    selenium_coam.logout
    sleep   2min

Check ipsec tunnel is down
    [Documentation]   This keyword used to check ipsec status down
    csn.connect to    hostname=${asik_addr}     username=${asik_username}     password=${asik_password}    alias=gNB
    sleep    3s
    csn.send_command    command=ipsec statusall    connection=gNB
    sleep    5s
    ${ipsec_fail_statu}    csn.read output    connection=gNB
    should be empty    ${ipsec_fail_statu}
    Run Keyword And Ignore Error    csn.disconnect    connection=gNB

Check left gnb status with command
    [Documentation]   This keyword used to check gnb status with command
    csn.connect_to    hostname=${asik_addr}     username=${asik_username}     password=${asik_password}    alias=gNB
    sleep    5s
    csn.send_command    command=export PYTHONPATH=/opt/hwmt/python;python /opt/hwmt/python/hwapi/AdetS.py -s -n 0x2011   connection=gNB
    sleep    15s
    ${output1}    csn.read output    connection=gNB
    Should Match Regexp    ${output1}    0x20.*FSM2_FCT.*ready
    Should Match Regexp    ${output1}    0x22.*FSM2_FSP1.*ready
    Run Keyword And Ignore Error    csn.disconnect    connection=gNB

Validate and activate and check activate plan status for ipsec
    [Documentation]   This keyword used to validate and active plan despite errors
    selenium_coam.validate_plan
    sleep    3s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    3s
	#selenium.check_activate_plan_status