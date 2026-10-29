*** Settings ***
Documentation     author: Annie Hu
...               Group: HGZ_SG5
...               contact: Annie.hu@nokia-sbell.com


Library           ../../libraries/get_bts_info.py   WITH NAME    lib
Resource          ../../common/coam_resource.robot
#Library           ../Library/python_1178-170.py


*** Variables ***
@{e_list}
${proc}         CCSDaemonExe

*** Keywords ***
"${Step}" Check gNB precodition
    log to console    "${Step}" Check gNB precodition
    WEBUI Login
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    #${Output}    selenium_coam.get_ru_info
    ${output_tmp}    selenium_coam.get_ru_info
    ${RU_info}    set variable    ${output_tmp}[Status]
    should match regexp    ${RU_info}[Operational state]    Enabled
    ${output_tmp}    selenium_coam.get_cell_info
    ${Cell_info}    set variable    ${output_tmp}[Status]
    should be equal      ${Cell_info}[Operational state]    Enabled
    ${output_tmp}    selenium_coam.get_abil_info
    ${ABIL_info}    set variable    ${output_tmp}[Status]
    should be equal      ${ABIL_info}[Operational state]    Enabled
    WEBUI Logout

Check if gNB is not pingable
    ${output}   Run       ping -c 1 -W 10 10.57.227.230
    Should contain      ${output}   1 packets transmitted, 0 received

Check if gNB is pingable
    ${output}   Run       ping -c 1 -W 10 10.57.227.230
    Should contain      ${output}   1 packets transmitted, 1 received


"${Step}" Check gNB and Cell onAir
    Log To Console    "${Step}" Check gNB and Cell onAir
    BuiltIn.Log    Start checking bts reset result.
    Run Keyword And Ignore Error    WEBUI Logout
    WEBUI Login
    Wait Until Keyword Succeeds    21min    1min    Check gNB and Cell onAir
    sleep    5s
    BuiltIn.Log    BTS reset check finished, reset successfully.

"${Step}" Trigger Fault 4019
    log to console    Trigger Fault 4019
    csn.connect_to    hostname=${asik_addr}    username=${asik_username}
    ...   password=${asik_password}     alias=OAM
    csn.send command      command=bsh 1:0 killall /opt/hwr/HWRTimeSExe    connection=OAM
    #csn.execute     command=bsh 1:0    connection=OAM
    #csn.execute     command=killall /opt/hwr/HWRTimeSExe    connection=OAM
    csn.disconnect     connection=OAM
    sleep  5s

"${Step}" Trigger Fault 4383
     log to console    "${Step}" Trigger Fault 4383
     csn.connect_to    hostname=${asik_addr}    username=${asik_username}
     ...   password=${asik_password}     alias=asik
     #csn.send command    command=lxc-ls --active     connection=OAM
     #csn.send command    command= lxc-attach -n
     Virtual Node Should Be Available     virtual_node=0xe002      connection_ssh=asik
     Process On Virtual Node Should Be Running    process_command=${proc}   vn_address=0xe002   connection_ssh=asik
     Kill Process On Virtual Node
     csn.disconnect      connection=asik
     sleep   20s

Get Virtual Nodes
    ${virtual_nodes}    csn.execute    command=lxc-ls    connection=asik
    [Return]    ${virtual_nodes}

Virtual Node Should Be Available
    [Arguments]
    ...    ${virtual_node}
    ...    ${connection_ssh}=asik
    ${list_VNs}    Get Virtual Nodes
    List Should Contain Value    ${list_VNs}    ${virtual_node}

Kill Process On Virtual Node
    [Arguments]
    ...    ${vn_address}=0xe002
    ...    ${connection_ssh}=asik
    ...    ${pid}=${pid}
    csn.execute    command=lxc-attach -n ${vn_address} -- kill -9 ${pid}    connection=${connection_ssh}

Process On Virtual Node Should Be Running
    [Arguments]
    ...    ${process_command}
    ...    ${vn_address}=0xe002
    ...    ${connection_ssh}=asik

    ${VN_processes}    Get Processes From Virtual Node    virtual_node=${vn_address}    connection_ssh=asik
    ${process}      string.Get Lines Matching Pattern   ${VN_processes}      *${proc}*
    Should Not Be Empty    ${process}
    Extract PID from process    process=${process}

Extract PID from process
    [Arguments]
    ...     ${process}
    ${strip1}  fetch from left    ${process}      0.
    ${strip2}  remove string   ${strip1}   root
    ${pid}  strip string    ${strip2}
    set test variable  ${pid}

Get Processes From Virtual Node
    [Arguments]
    ...    ${virtual_node}=0xe002
    ...    ${connection_ssh}=asik
    csn.send command    command=lxc-attach -n ${virtual_node} -- ps aux    connection=asik
    ${VN_processes}    csn.read output    connection=asik
    [Return]    ${VN_processes}


Obtain_MRBTSID
    Wait Until Keyword Succeeds   3m   10s   WEBUI Login
    Get MRBTS Id online
    WEBUI Logout

Get MRBTS Id online
    log to console    Get MRBTS Id online
    ${mrbtsId}    Wait Until Keyword Succeeds    2min    10s    selenium_coam.get_parameter_value
    ...    dist_name=MRBTS-${mrbtsId}    filter_param=Multi Radio BTS Instance Id
    ${mrbts_id}=    Set Variable    MRBTS-${mrbtsId}
    set suite variable    ${mrbts_id}
    sleep    2s

Backup_SCF_file_on_WebEM
    log to console    Backup_SCF_file_on_WebEM
    ${flag_result}   ${scf_file}    Run Keyword And Ignore Error    selenium_coam.backup_bts_site_configuration    download_timeout=600
    sleep    5s
    ${scf_file_path}    OperatingSystem.Copy File    ${scf_file}    ${SAVE LOG DIRECTORY}
    set suite variable     ${scf_file_path}

Case setup
    cOAM Common Test Setup
    WEBUI Login
    Obtain_BTS_Name_ID
    #check RU STATUS

Obtain_BTS_Name_ID
    Backup_SCF_file_on_WebEM
    ${mrbtsId}    lib.Get_MRBTSID_cOAM    scf_path=${scf_file_path}
    ${nrbtsId}    lib.Get_NRBTSID_cOAM    scf_path=${scf_file_path}
    set suite variable     ${mrbtsId}
    set suite variable     ${nrbtsId}
    ${BTS_Name}    Wait Until Keyword Succeeds    2min    10s
    ...    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsId}    filter_param=BTS name
    set suite variable     ${BTS_Name}

Case teardown
    Run Keyword And Ignore Error   WEBUI Logout

Check fault on WebUI
    [Arguments]    ${alarm_filter}   ${Alarm_ID_CP}    ${Alarm_name_CP}    ${Fault_name_CP}
    #WEBUI Login
    @{alarm info}=    Wait Until Keyword Succeeds    1min    2s
    ...    selenium_coam.get_active_alarm_info    alarm_filter=${alarm_filter}    timeout=100
    ${fault_dic}   set variable    ${alarm info}[0]
    ${Alarm_ID}    set variable    ${fault_dic}[Alarm ID]
    ${Alarm_name}    set variable    ${fault_dic}[Alarm name]
    #${Fault_ID}    set variable    &{fault_dic}[Fault ID]
    ${Fault_name}    set variable    ${fault_dic}[Fault name]
    #${Severity}    set variable    &{fault_dic}[Severity]
    should be equal     ${Alarm_ID}     ${Alarm_ID_CP}
    should be equal     ${Alarm_name}     ${Alarm_name_CP}
    #should be equal     ${Fault_ID}     ${Fault_ID_CP}
    should be equal     ${Fault_name}     ${Fault_name_CP}
    #should be equal     ${Severity}     ${Severity_CP}
    #should be equal     ${Alarming_object}     ${Alarm_ob_CP}

Check fault appear on WebUI
    [Arguments]    ${alarm_filter}
    @{alarm info}=    Wait Until Keyword Succeeds    1min    2s
    ...    selenium_coam.get_history_alarm_info    alarm_filter=${alarm_filter}    timeout=100
    #should be equal    ${alarm info}    ${e_list}
    ${result}=    Run Keyword If    "${alarm info}"=="${e_list}"     set variable     False
    ...   ELSE    set variable     True
    [Return]  ${result}

Check fault disappear on WebUI
    [Arguments]    ${alarm_filter}
    @{alarm info}=    Wait Until Keyword Succeeds    5min    10s
    ...    selenium_coam.get_active_alarm_info    alarm_filter=${alarm_filter}    timeout=100
    should be equal    ${alarm info}    ${e_list}


"${Step}" Check BBMOD is restarted
     log to console    "${Step}" Check BBMOD is restarted
     WEBUI Login
     wait until keyword succeeds    1min    2s    BBMOD is restarted

BBMOD is restarted
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    ${output_tmp}    selenium_coam.get_abil_info
    ${output}    set variable    ${output_tmp}[Status]
    run keyword and ignore error    should be equal      ${output}[Operational state]      Disabled
    #BBMODrun keyword and ignore error    should be equal      &{output}[Administrative state]    Unlocked
    run keyword and ignore error    should be equal      ${output}[Availability status]     Offline
    run keyword and ignore error    should be equal      ${output}[Procedural status]     not initialized


"${Step}" Check Cell and RU is restarted
    log to console    "${Step}" Check Cell and RU is restarted
    wait until keyword succeeds    1min    1s    RU is restarted
    wait until keyword succeeds   1min    1s   Cell is restarted


RU is restarted
    #run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    ${output_tmp}    selenium_coam.get_ru_info
    ${RU_info}    set variable    ${output_tmp}[Status]
    should match regexp    ${RU_info}[Operational state]    Disabled
    #should match regexp    &{RU_info}[Availability status]     NotInstalled
    #should match regexp    &{RU_info}[Administrative state]     Unlocked

Cell is restarted
    #run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    ${output_tmp}    selenium_coam.get_cell_info
    ${Cell_info}    set variable    ${output_tmp}[Status]
    should be equal      ${Cell_info}[Operational state]    Disabled
    should be equal      ${Cell_info}[Availability status]    Failed
    #should be equal      &{Cell_info}[Administrative state]     Unlocked

Check gNB and Cell onAir
    Run Keyword And Ignore Error    WEBUI Logout
    WEBUI Login
    Wait Until Keyword Succeeds    15min    1min    check RU STATUS
    Wait Until Keyword Succeeds    15min    1min    Check Cell is UP
	Wait Until Keyword Succeeds    15min    1min
    ...    check gNB Staus onAir    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}    search_text=Operational state
    WEBUI Logout

Check if BBMOD is not pingable
    csn.connect_to    hostname=${asik_addr}    username=${asik_username}
    ...   password=${asik_password}     alias=asik
    csn.send command      command=ping -c 1 -W 10 192.168.253.20    connection=asik
    ${output}      csn.read output          connection=asik
    Should contain      ${output}   1 packets transmitted, 0 received
    csn.send command      command=ping -c 1 -W 10 192.168.253.21   connection=asik
    ${output}      csn.read output          connection=asik
    Should contain      ${output}   1 packets transmitted, 0 received
     csn.send command      command=ping -c 1 -W 10 192.168.253.22   connection=asik
    ${output}      csn.read output          connection=asik
    Should contain      ${output}   1 packets transmitted, 0 received
    csn.disconnect      connection=asik

Check if BBMOD is pingable
     csn.connect_to    hostname=${asik_addr}    username=${asik_username}
    ...   password=${asik_password}     alias=asik
    csn.send command      command=ping -c 1 -W 10 192.168.253.20    connection=asik
    ${output}      csn.read output          connection=asik
    Should contain      ${output}   1 packets transmitted, 1 received
    csn.send command      command=ping -c 1 -W 10 192.168.253.21   connection=asik
    ${output}      csn.read output          connection=asik
    Should contain      ${output}   1 packets transmitted, 1 received
     csn.send command      command=ping -c 1 -W 10 192.168.253.22   connection=asik
    ${output}      csn.read output          connection=asik
    Should contain      ${output}   1 packets transmitted, 1 received
    csn.disconnect      connection=asik
