*** Settings ***
Library           OperatingSystem
Library           Collections
Library           Process
Library           DateTime
Library           String
Library           testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/get_bts_info.py   WITH NAME    lib
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Resource          taf/rfrl/common_resources/robot/connection_alias_store.robot

*** Variables ***
@{e_list}
${filter_param}    X2C link lock
${LTEENB_ID}       1
@{X2link_value}    locked    unlocked
${enb_addr}        ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${enb_username}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
${enb_password}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.password}

*** Keywords ***
Check_gNB_status
    Wait Until Keyword Succeeds    5min    1min    coam_resource.WEBUI Login
    Obtain_BTS_Name_ID
    ${status}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}
    ...    filter_param=Operational state    abbr=operationalState
    should be equal    ${status}    onAir
    #coam_resource.check gNB Staus onAir    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}    search_text=Operational state
    coam_resource.WEBUI Logout
    ${is_asib}     If ASIB card used
    ${asib_flag}      convert to string    ${is_asib} 
    set suite variable      ${asib_flag}     
    
Obtain_BTS_Name_ID
    #${mrbtsId}    Wait Until Keyword Succeeds    2min    10s    selenium_coam.get_bts_id
    #${BTS_Name}    Wait Until Keyword Succeeds    2min    10s    selenium_coam.get_bts_name
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

Check fault on WebEM
    [Arguments]    ${alarm_filter}   ${Alarm_ID_CP}    ${Alarm_name_CP}    ${Fault_ID_CP}
    ...    ${Fault_name_CP}    ${Severity_CP}    ${Alarm_ob_CP}
    #Run Keyword and Ignore Error    selenium_coam.refresh_page
    coam_resource.WEBUI Login
    @{alarm info}=    selenium_coam.get_active_alarm_info    alarm_filter=${alarm_filter}    timeout=100
    ${fault_dic}   set variable    ${alarm info}[0]
    ${Alarm_ID}    set variable    ${fault_dic}[Alarm ID]
    ${Alarm_name}    set variable    ${fault_dic}[Alarm name]
    ${Fault_ID}    set variable    ${fault_dic}[Fault ID]
    ${Fault_name}    set variable    ${fault_dic}[Fault name]
    ${Severity}    set variable    ${fault_dic}[Severity]
    #${Alarming_object}    set variable    &{fault_dic}[Alarming object]
    should be equal     ${Alarm_ID}     ${Alarm_ID_CP}
    should be equal     ${Alarm_name}     ${Alarm_name_CP}
    should be equal     ${Fault_ID}     ${Fault_ID_CP}
    should be equal     ${Fault_name}     ${Fault_name_CP}
    should be equal     ${Severity}     ${Severity_CP}
    #run keyword and ignore error    should be equal     ${Alarming_object}     ${Alarm_ob_CP}

Trigger alarm on gNB Slave
    [Arguments]  ${cmd}
    #csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=ASIK Master
    Connect to Common Unit Master
    Connect to Common Unit Slave
    csn.send command    command=${cmd}    connection=ASIK Slave
    run keyword and ignore error    csn.disconnect    connection=ASIK Slave
    run keyword and ignore error    csn.disconnect    connection=ASIK Master

Trigger alarm on gNB
    [Arguments]  ${cmd}
    csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=ASIK
    csn.send command    command=${cmd}    connection=ASIK
    run keyword and ignore error    csn.disconnect    connection=ASIK
    run keyword and ignore error    csn.disconnect    connection=ASIK

Trigger alarm on eNB
    [Arguments]  ${cmd}
    csn.connect to    hostname=${enb_addr}    username=${enb_username}    password=${enb_password}    alias=enb
    csn.send command    command=${cmd}    connection=enb
    run keyword and ignore error    csn.disconnect    connection=enb
    run keyword and ignore error    csn.disconnect    connection=enb

Clear fault on gNB
    #csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gNB
    #csn.send command    command=reboot    connection=gNB
    #run keyword and ignore error    csn.disconnect    connection=gNB
    csn.connect to    hostname=${enb_addr}    username=${enb_username}    password=${enb_password}    alias=eNB
    csn.send command    command=reboot    connection=eNB
    run keyword and ignore error    csn.disconnect    connection=eNB
    Wait Until Keyword Succeeds    3min    30s    coam_resource.WEBUI Login
    Wait Until Keyword Succeeds    1min    30s   selenium_coam.reset_site
    Wait Until Keyword Succeeds    10min    1min    coam_resource.WEBUI Login
    Wait Until Keyword Succeeds    15min    1min    
    ...    coam_resource.check gNB Staus onAir    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}    search_text=Operational state
    coam_resource.WEBUI Logout
    
Check fault disappear on WebEM
    [Arguments]    ${alarm_filter}
    @{alarm info}=    Wait Until Keyword Succeeds    5min    10s
    ...    selenium_coam.get_active_alarm_info    alarm_filter=${alarm_filter}    timeout=100
    should be equal    ${alarm info}    ${e_list}

Trigger fault 7300 on WebEM
    coam_resource.WEBUI Login
    ${x2_status}    Wait Until Keyword Succeeds    1min    10s
    ...    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/LTEENB-${LTEENB_ID}    filter_param=${filter_param}
    Run keyword if    '${x2_status}' != '${X2link_value[0]}'    Change_X2status    X2link_status=${X2link_value[0]}

Clear fault 7300 on WebEM
    coam_resource.WEBUI Login
    ${x2_status}    Wait Until Keyword Succeeds    1min    10s
    ...    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/LTEENB-${LTEENB_ID}    filter_param=${filter_param}
    Run keyword if    '${x2_status}' != '${X2link_value[1]}'    Change_X2status    X2link_status=${X2link_value[1]}

Change_X2status
    [Arguments]    ${X2link_status}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/LTEENB-${LTEENB_ID}    filter_param=${filter_param}
    ...    new_value=${X2link_status}
    coam_resource.Validate and activate and check activate plan status
    ${current_value}    Wait Until Keyword Succeeds    1min    10s
    ...    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/LTEENB-${LTEENB_ID}    filter_param=${filter_param}
    should be equal    ${current_value}    ${X2link_status}

Teardown_fault_clear
    [Arguments]    ${alarm_filter}
    run keyword and ignore error    Clear fault on gNB
    run keyword and ignore error    coam_resource.WEBUI Login
    run keyword and ignore error    Check fault disappear on WebEM    alarm_filter=${alarm_filter}
    run keyword and ignore error    coam_resource.WEBUI Logout
