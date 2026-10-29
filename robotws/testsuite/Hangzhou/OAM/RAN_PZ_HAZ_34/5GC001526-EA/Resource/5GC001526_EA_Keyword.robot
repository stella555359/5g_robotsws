*** Settings ***
#Library           taf.transport.ssh    WITH NAME    csn
Library           ${CURDIR}/../../libraries/get_bts_info.py
Resource          ${CURDIR}/../../common/coam_resource.robot
Library           OperatingSystem
Library           Process
Library           Collections
Library           DateTime
Library           String


*** Variables ***
${MRBTS_ID}                 2265
${WEBUI_URL}                https://${asik_addr}/
${ipsec_commission_file}    /home/nokia/commission/scf_MRBTS-2265.xml
${vm_path}                  /home/nokia/
${create_backup_dir}        backupscf/
${Strongswan_addr}         10.57.167.5
${Strongswan_USER}         root
${Stswan_PASSWORD}         nokia123
${gnb_S1Uplane}            ${tl.gnbs[0].cu.s1u.v4}
${gnb_X2Cplane}            ${tl.gnbs[0].cu.x2c.v4}
${gnb_Mplane}              ${tl.gnbs[0].cu.f1m.v4}
${gnb_X2Uplane}            ${tl.gnbs[0].cu.x2u.v4}
${gnb_X2Cplane_subnet}     ${tl.gnbs[0].cu.tracing.v4}
${switch_subnet1}          10.57.248.113
${switch_subnet2}          10.57.248.113
${switch_subnet3}          10.57.248.112
${gnb_S1Uplanev6}          ${tl.gnbs[0].cu.s1u.v6}
${gnb_X2Cplanev6}          ${tl.gnbs[0].cu.x2c.v6}
${gnb_Mplanev6}            ${tl.gnbs[0].cu.f1m.v6}
${gnb_X2Uplanev6}          ${tl.gnbs[0].cu.x2u.v6}
${gnb_X2Uplanev6_2}        ${tl.gnbs[0].cu.tracing.v6}
${switch_subnet1v6}        2a00:8a00:8000:136:10:57:248:72
${switch_subnet2v6}        2a00:8a00:8000:136:10:57:248:71
${7750_switch_interface}    10.57.143.157
${7750_switch_interface_v6}    2a00:8a00:8000:136:10:57:143:157
${enb_ip}                  ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}

*** Keywords ***

Import ipsec commission file
    Login BTS via WebUI and check HW state
  #  Backup commission file via WebUI
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
    sleep    10min

Check HW state with ipsec commission file
    log to console    Check HW state with ipsec commission file
    wait until keyword succeeds    10min    1min    Check ASIK status with command
    sleep    3s

Delete backup commission file
    csn.connect to    ${host_addr}    ${host_username}    ${host_password}    alias=VM
    csn.send_command    command=cd ${vm_path};rm -rf ${create_backup_dir}    connection=VM
    csn.disconnect    connection=VM

Import previous backup commission file
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${backup_scf_path_file}
    sleep   3s
    Validate and activate and check activate plan status
    sleep    3s
    run keyword and ignore error    selenium_coam.logout
    sleep   2min

Validate and activate and check activate plan status for IPSEC
    selenium_coam.validate_plan
    sleep    3s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    3s


Check ipsec tunnel is down
    csn.connect to    ${asik_addr}    ${asik_username}    ${asik_password}    alias=gNB
    sleep    3s
    csn.send_command    command=ipsec statusall    connection=gNB
    sleep    5s
    ${ipsec_fail_statu}    csn.read output    connection=gNB
    should be empty    ${ipsec_fail_statu}
    Run Keyword And Ignore Error    csn.disconnect    connection=gNB