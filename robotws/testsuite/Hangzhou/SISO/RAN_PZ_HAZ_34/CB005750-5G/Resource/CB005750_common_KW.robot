*** Settings ***
Documentation     author: annie.hu
...               Group: HGZ_SG5
...               contact: annie.hu@nokia-sbell.com

#Resource          ../../../../OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Resource          ../../../../SISO/RAN_PZ_HAZ_34/common/siso_resource.robot

*** Variables ***
@{e_list}
${proc}         CCSDaemonExe


*** Keywords ***
"${Step}" Trigger Fault 4383 With ASIL_ABIO
     log to console    "${Step}" Trigger Fault 4383
     csn.connect_to    hostname=${asik_addr}    username=${asik_username}
     ...   password=${asik_password}     alias=asil
     Virtual Node Should Be Available With ASIL     virtual_node=0x1510      connection_ssh=asil
     Process On Virtual Node Should Be Running With ASIL    process_command=${proc}   vn_address=0x1510   connection_ssh=asib
     Kill Process On Virtual Node With ASIL
     csn.disconnect      connection=asil
     sleep   20s

Get Virtual Nodes With ASIL
    ${virtual_nodes}    csn.execute    command=lxc-ls    connection=asil
    [Return]    ${virtual_nodes}

Virtual Node Should Be Available With ASIL
    [Arguments]
    ...    ${virtual_node}
    ...    ${connection_ssh}=asil
    ${list_VNs}    Get Virtual Nodes With ASIL
    List Should Contain Value    ${list_VNs}    ${virtual_node}

Kill Process On Virtual Node With ASIL
    [Arguments]
    ...    ${vn_address}=0x1510
    ...    ${connection_ssh}=asil
    ...    ${pid}=${pid}
    csn.execute    command=lxc-attach -n ${vn_address} -- kill -9 ${pid}    connection=${connection_ssh}

Process On Virtual Node Should Be Running With ASIL
    [Arguments]
    ...    ${process_command}
    ...    ${vn_address}=0x1510
    ...    ${connection_ssh}=asil

    ${VN_processes}    Get Processes From Virtual Node With ASIL    virtual_node=${vn_address}    connection_ssh=asil
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

Get Processes From Virtual Node With ASIL
    [Arguments]
    ...    ${virtual_node}=0x1510
    ...    ${connection_ssh}=asil
    csn.send command    command=lxc-attach -n ${virtual_node} -- ps aux    connection=asil
    ${VN_processes}    csn.read output    connection=asil
    [Return]    ${VN_processes}


"${Step}" Check gNB precodition
    log to console    "${Step}" Check gNB precodition
    WEBUI Login
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    ${output_tmp}    selenium_coam.get_ru_info
    ${RU_info}    set variable    ${output_tmp}[Status]
    should match regexp    ${RU_info}[Operational state]    (Enabled|enable)
    ${output_tmp}    selenium_coam.get_cell_info
    ${Cell_info}    set variable    ${output_tmp}[Status]
    should be equal      ${Cell_info}[Operational state]    Enabled     ignore_case=${True}
    ${output_tmp}    selenium_coam.get_abil_info
    ${ABIL_info}    set variable    ${output_tmp}[Status]
    should be equal      ${ABIL_info}[Operational state]    Enabled     ignore_case=${True}
    WEBUI Logout

Check if gNB is not pingable With ASIL
    ${output}   Run       ping -c 1 -W 10 10.101.50.170
    Should contain      ${output}   1 packets transmitted, 0 received

Check if gNB is pingable With ASIL
    ${output}   Run       ping -c 1 -W 10 10.101.50.170
    Should contain      ${output}   1 packets transmitted, 1 received

Check if gNB is not pingable	
    ${output}   Run       ping -c 1 -W 10 ${tl.gnbs[0].dus[0].f1_m_ip_addr}
    Should contain      ${output}   1 packets transmitted, 0 received
	
Check if gNB is pingable
    ${output}   Run       ping -c 1 -W 10 ${tl.gnbs[0].dus[0].f1_m_ip_addr}
    Should contain      ${output}   1 packets transmitted, 1 received

"${Step}" Check gNB and Cell onAir
    Log To Console    "${Step}" Check gNB and Cell onAir
    Run Keyword And Ignore Error    WEBUI Logout
    WEBUI Login
    Wait Until Keyword Succeeds    10min    1min    Check gNB and Cell onAir
    sleep    5s

"${Step}" Trigger Fault 4019
    log to console    Trigger Fault 4019
    csn.connect_to    hostname=${asik_addr}    username=${asik_username}
    ...   password=${asik_password}     alias=OAM
    csn.send command      command=bsh 1:0 killall /opt/hwr/HWRTimeSExe    connection=OAM
    csn.disconnect     connection=OAM
    sleep  20s


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
    @{alarm info}=    Wait Until Keyword Succeeds    15min    10s
    ...    selenium_coam.get_active_alarm_info    alarm_filter=${alarm_filter}    timeout=100
    should be equal    ${alarm info}    ${e_list}


"${Step}" Check BBMOD is restarted
     log to console    "${Step}" Check BBMOD is restarted
     WEBUI Login
     wait until keyword succeeds    10min    2s    BBMOD is restarted

BBMOD is restarted
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    Run Keyword and Ignore Error    selenium_coam.refresh_page
    ${is_startup_window_exist}=    Run Keyword And Ignore Error    selenium_coam.start_up_view_window_exists
    Run Keyword If    '${is_startup_window_exist[0]}'=='PASS'    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${output_tmp}    selenium_coam.get_abil_info
    ${output}    set variable    ${output_tmp}[Status]
    should be equal      ${output}[Operational state]      Disabled    ignore_case=${True}
    #BBMODrun keyword and ignore error    should be equal      &{output}[Administrative state]    Unlocked
    should match regexp    ${output}[Availability status]     (offline|off line)
    should be equal      ${output}[Procedural status]      initializing


"${Step}" Check Cell and RU is restarted
    log to console    "${Step}" Check Cell and RU is restarted
    wait until keyword succeeds    1min    1s    RU is restarted
    wait until keyword succeeds   1min    1s   Cell is restarted


RU is restarted
    #run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    ${output_tmp}    selenium_coam.get_ru_info
    ${RU_info}    set variable    ${output_tmp}[Status]
    should match regexp    ${RU_info}[Operational state]    Disabled
    #should match regexp    ${RU_info}[Availability status]     NotInstalled
    #should match regexp    ${RU_info}[Administrative state]     Unlocked

Cell is restarted
    #run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    ${output_tmp}    selenium_coam.get_cell_info
    ${Cell_info}    set variable    ${output_tmp}[Status]
    should be equal      ${Cell_info}[Operational state]    Disabled
    should be equal      ${Cell_info}[Availability status]    Failed
    #should be equal      ${Cell_info}[Administrative state]     Unlocked

Check gNB and Cell onAir
    Run Keyword And Ignore Error    WEBUI Logout
    WEBUI Login
    #Wait Until Keyword Succeeds    15min    1min    check RU STATUS
    Wait Until Keyword Succeeds    25min    1min    Check Cell is UP
    Wait Until Keyword Succeeds    25min    1min
    ...    check gNB Staus onAir    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}    search_text=Operational state
    WEBUI Logout

Check if BBMOD is pingable With ABIO
     csn.connect_to    hostname=${asik_addr}    username=${asik_username}
    ...   password=${asik_password}     alias=asil
    csn.send command      command=ping -c 1 -W 10 192.168.253.20    connection=asil
    ${output}      csn.read output          connection=asil
    Should contain      ${output}   1 packets transmitted, 1 received
    csn.send command      command=ping -c 1 -W 10 192.168.253.21   connection=asil
    ${output}      csn.read output          connection=asil
    Should contain      ${output}   1 packets transmitted, 1 received
     csn.send command      command=ping -c 1 -W 10 192.168.253.22   connection=asil
    ${output}      csn.read output          connection=asil
    Should contain      ${output}   1 packets transmitted, 1 received
    csn.disconnect      connection=asil



"${Step}" Check Fault 4019 appears on WebUI
    Log to console    "Step 3" Check Fault 4019 appears on webUI
    WEBUI Login
     Wait until keyword succeeds    1min    2s    Check fault on WebUI
    ...    alarm_filter=${alarm_filter}   Alarm_ID_CP=${Alarm_ID_CP}    Alarm_name_CP=${Alarm_name_CP}    Fault_ID_CP=${Fault_ID_CP}
    ...    Fault_name_CP=${Fault_name_CP}

"${Step}" Check Fault 4019 clear on WebUI
   log to console  Check Fault 4019 clear on WebUI
   WEBUI Login
   wait until keyword succeeds    10min    5s    Check fault disappear on WebUI    alarm_filter=${alarm_filter}


"${Step}" Trigger Fault 4019 for 3 times
    FOR    ${i}    IN RANGE    1    4
        log to console    Fault Trigger Snapshot ${i} time
        "Step 2" Trigger Fault 4019
        "Step 2" Check BBMOD is restarted
        "Step 2" Check Fault 4019 clear on WebUI
   #     "Step 2" Check gNB and Cell onAir
        sleep   30s
    END
    "Step 2" Trigger Fault 4019
     #sleep   20s

"${Step}" Check BBMOD no reset as recovery action
    log to console    "${Step}" Check ABIO no reset as recovery action
    Wait Until Keyword Succeeds  8 min  2s   Check if BBMOD is pingable With ABIO


"${Step}" Check gNB autonomous reset as a recovery action
    log to console    "${Step}" Check gNB is restarted
    #Wait Until Keyword Succeeds  4 min  2s  Check if gNB is not pingable With ASIL
    Wait Until Keyword Succeeds  15 min  1s  Check if gNB is not pingable
    #Wait Until Keyword Succeeds  4 min  2s  Check if gNB is pingable With ASIL
    Wait Until Keyword Succeeds  15 min  1s  Check if gNB is pingable

Recover Env
    log to console    Recover Env
    WEBUI Login
    Run Keyword     run keyword if test failed   selenium_coam.reset_site
    sleep    10min
    "After Reset" Check gNB and Cell onAir

"${Step}" Check If Fault 4383 Was Raised
   log to console    "${Step}" Check If Fault 4383 Was Raised
   csn.connect_to    hostname=${asik_addr}    username=${asik_username}
    ...   password=${asik_password}     alias=asil
     csn.send command     command=cat ${BLACKBOX_ALARMS_PATH} | grep 4383
    ...    connection=asil
    ${status}      csn.read output     connection=asil
    Should contain   ${status}    4383

"${Step}" Trigger Fault 4383 for 3 times
    FOR    ${i}    IN RANGE    1    4
        log to console    Fault Trigger Snapshot ${i} time
        "Step 2" Trigger Fault 4383 With ASIL_ABIO
        "Step 2" Check gNB autonomous reset as a recovery action
        "Step 2" Check gNB and Cell onAir
        "Step 2" Check Fault 4383 disappear on WebUI
    END
    "Step 2" Trigger Fault 4383 With ASIL_ABIO

"${Step}" Check Fault 4383 disappear on WebUI
    log to console    "${Step}"  Check Fault 4383 disappear on WebUI
    WEBUI Login
    Run keyword      Check fault disappear on WebUI      alarm_filter=${alarm_filter}

"${Step}" Check gNB no reset as recovery action
    log to console    "${Step}" Check gNB no reset as recovery action
    Wait Until Keyword Succeeds  4 min  2s  Check if gNB is pingable With ASIL


General_OAM_Autonomous_recovery_reset_counter_BBMOD_SMOD
     [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to check Autonomous_recovery_reset_counter_BBMOD_SMOD.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 12.18.2020 - - Created
    ...    *******************
    ...    Owner_juanjuan.liu@nokia-sbell.com
    ${ALLOWED_FAULT_TEMP}    Copy List    ${ALLOWED_FAULT}
    ${Fault_6450}    Create Dictionary    faultId=${6450}
    Append to list     ${ALLOWED_FAULT_TEMP}    ${Fault_6450}
    Set Test Variable    ${ALLOWED_FAULT}    ${ALLOWED_FAULT_TEMP}
    "Step 1" Check gNB precodition
    "Step 2" Trigger Fault 4019 for 3 times
    #"Step 3" Check BBMOD no reset as recovery action
    "Step 3" Check gNB autonomous reset as a recovery action
    "Step 4" Check Fault 4019 clear on WebUI
    #Recover Env

General_OAM_Autonomous_recovery_reset_counter_SMOD
      [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to check Autonomous_recovery_reset_counter_SMOD.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 12.18.2020 - - Created
    ...    *******************
    ...    Owner_juanjuan.liu@nokia-sbell.com
    ${ALLOWED_FAULT_TEMP}    Copy List    ${ALLOWED_FAULT}
    ${Fault_6450}    Create Dictionary    faultId=${6450}
    Append to list     ${ALLOWED_FAULT_TEMP}    ${Fault_6450}
    Set Test Variable    ${ALLOWED_FAULT}    ${ALLOWED_FAULT_TEMP}
    "Step 1" Check gNB precodition
    "Step 2" Trigger Fault 4383 for 3 times
    "Step 3" Check gNB no reset as recovery action
    Recover Env
