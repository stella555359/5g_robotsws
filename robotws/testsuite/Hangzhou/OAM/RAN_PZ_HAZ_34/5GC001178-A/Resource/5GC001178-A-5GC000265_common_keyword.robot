*** Settings ***
Documentation     author: Annie Hu
...               Group: HGZ_SG5
...               contact: Annie.hu@nokia-sbell.com


Library           taf.transport.ssh    WITH NAME    csn
Library           ../../libraries/get_bts_info.py   WITH NAME    lib
Resource          ../../common/coam_resource.robot



*** Variables ***
#${Strongswan_addr}         10.57.159.121
#${Strongswan_USER}         root
#${Stswan_PASSWORD}         nokia123
${new_value}           true
${old_value}           false

${gnb_Mplane}              ${tl.gnbs[0].cu.f1m.v4}
#${gnb_ngCplane}            ${tl.gnbs[0].cu.ngc.v4}
#${gnb_ngUplane}            ${tl.gnbs[0].cu.ngu.v4}
#${gnb_xnCplane}            ${tl.gnbs[0].cu.xnc.v4}
#${gnb_xnUplane}            ${tl.gnbs[0].cu.xnu.v4}
#${gnb_xnUplane_subnet}     ${tl.gnbs[0].cu.tracing.v4}
${gnb_S1Uplane}            ${tl.gnbs[0].cu.s1u.v4}
${gnb_X2Cplane}            ${tl.gnbs[0].cu.x2c.v4}
${gnb_X2Uplane}            ${tl.gnbs[0].cu.x2u.v4}
${gnb_Mplanev6}            ${tl.gnbs[0].cu.f1m.v6}
${gnb_ngCplanev6}          ${tl.gnbs[0].cu.ngc.v6}
#${gnb_ngUplanev6}          ${tl.gnbs[0].cu.ngu.v6}
#${gnb_xnCplanev6}          ${tl.gnbs[0].cu.xnc.v6}
#${gnb_xnUplanev6}          ${tl.gnbs[0].cu.xnu.v6}
#${gnb_xnUplane_subnetv6}   ${tl.gnbs[0].cu.tracing.v6}
${gnb_S1Uplanev6}          ${tl.gnbs[0].cu.s1u.v6}
${gnb_X2Cplanev6}          ${tl.gnbs[0].cu.x2c.v6}
${gnb_X2Uplanev6}          ${tl.gnbs[0].cu.x2u.v6}
${gnb_X2Uplanev6_2}        ${tl.gnbs[0].cu.tracing.v6}



#${gnb_Mplane}              10.57.227.235
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

#${gnb_S1Uplane}            ${tl.gnbs[0].cu.s1u.v4}
#${gnb_X2Cplane}            ${tl.gnbs[0].cu.x2c.v4}
${gnb_Mplane}              ${tl.gnbs[0].cu.f1m.v4}
#${gnb_X2Uplane}            ${tl.gnbs[0].cu.x2u.v4}
#${gnb_X2Cplane_subnet}     ${tl.gnbs[0].cu.tracing.v4}
#${switch_subnet1}          10.57.248.1
#${switch_subnet2}          10.57.248.113
#${switch_subnet3}          10.57.248.112
#${gnb_S1Uplanev6}          ${tl.gnbs[0].cu.s1u.v6}
#${gnb_X2Cplanev6}          ${tl.gnbs[0].cu.x2c.v6}
#${gnb_Mplanev6}            ${tl.gnbs[0].cu.f1m.v6}
#${gnb_X2Uplanev6}          ${tl.gnbs[0].cu.x2u.v6}
#${gnb_X2Uplanev6_2}        ${tl.gnbs[0].cu.tracing.v6}
#${switch_subnet1v6}        2a00:8a00:8000:136:10:57:248:1
#${switch_subnet2v6}        2a00:8a00:8000:136:10:57:248:71
#${7750_switch_ipv4}        10.57.143.157
#${7750_switch_ipv6}        2a00:8a00:8000:136:10:57:143:157
#${enb_ip}                  ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}

*** Keywords ***
Case setup
    cOAM Common Test Setup
    WEBUI Login
    Obtain_BTS_Name_ID

Obtain_BTS_Name_ID
    Backup_SCF_file_on_WebEM
    ${mrbtsId}    lib.Get_MRBTSID_cOAM    scf_path=${scf_file_path}
    ${nrbtsId}    lib.Get_NRBTSID_cOAM    scf_path=${scf_file_path}
    set suite variable     ${mrbtsId}
    set suite variable     ${nrbtsId}
    ${BTS_Name}    Wait Until Keyword Succeeds    2min    10s
    ...    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsId}    filter_param=BTS name
    set suite variable     ${BTS_Name}

Backup_SCF_file_on_WebEM
    log to console    Backup_SCF_file_on_WebEM
    ${flag_result}   ${scf_file}    Run Keyword And Ignore Error    selenium_coam.backup_bts_site_configuration    download_timeout=600
    sleep    5s
    ${scf_file_path}    OperatingSystem.Copy File    ${scf_file}    ${SAVE LOG DIRECTORY}
    set suite variable     ${scf_file_path}

Case teardown
    Run Keyword And Ignore Error   WEBUI Logout

Set icmpResponseEnabled disable
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/IPNO-1    filter_param=${search_text}
    ...   new_value=${old_value}
    Validate and activate and check activate plan status
    sleep    3s

Set icmpResponseEnabled enable
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/IPNO-1    filter_param=${search_text}
    ...  new_value=${new_value}
    Validate and activate and check activate plan status
    sleep    3s

Check left gnb status with command
    csn.connect_to    hostname=${asik_addr}    username=${asik_username}
    ...   password=${asik_password}    alias=gNB
    sleep    5s
    csn.send_command    command=export PYTHONPATH=/opt/hwmt/python;python /opt/hwmt/python/hwapi/AdetS.py -s -n 0x2011   connection=gNB
    sleep    15s
    ${output1}    csn.read output    connection=gNB
    Should Match Regexp    ${output1}    0x20.*FSM2_FCT.*ready
    Should Match Regexp    ${output1}    0x22.*FSM2_FSP1.*ready
    Run Keyword And Ignore Error    csn.disconnect    connection=gNB

Recover icmpResponseEnabled Enable
    log to console    teardown: Recover ipsec Enable
    #wait until keyword succeeds    10min    1min    WEBUI Login
    ${online_value}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/IPNO-1     filter_param=${search_text}
	set suite variable    ${online_value}
    sleep    3s
	Run Keyword If     "${online_value}" == "${new_value}"    Log    \n**sueccess**\n
    ...    ELSE    Set icmpResponseEnabled enable
	sleep    10s
	WEBUI Logout