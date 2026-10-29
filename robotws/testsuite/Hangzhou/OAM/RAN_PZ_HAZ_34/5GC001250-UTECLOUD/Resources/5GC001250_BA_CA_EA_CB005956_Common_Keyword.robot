*** Settings ***
Documentation     author: y63li
...               Group: 5G_PZ_MMW_HZ_3_SG
...               contact: ying.15.li@nokia-sbell.com

Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/siso_resource.robot
Library           testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/get_bts_info.py   WITH NAME    lib
Library           taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library           taf.transport.ssh    WITH NAME    csn
Library           5GC001250-CA.py
Library           OperatingSystem
Library           Collections
Library           taf.pdu
Library           String
Library           Process
Library           taf.pdu    WITH NAME    pdu

*** Variables ***
${DU_OAM_IP}            ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${CU_OAM_IP}            ${tl.gnbs[0].cu.oam_http_connection_details.addr}

${WEBUI_URL}        https://${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBUI_USER}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}   ${tl.gnbs[0].cu.oam_http_connection_details.password}

${connection}     DU_OAM
${scf_name}    scf_5GC001250.xml
${tmp_log_dir}    /home/ute/logs
${testline}  7_5_UTE5G401T906
${alarm_filter1}    ToP reference missing
${alarm_filter2}    Toggling: ToP reference missing (4298)
${alarm_filter_10}    No connection to unit
${alarm_filter_05}    SSH enabled
${invalid_ip}        10.57.249.162
${valid_ip}        10.57.249.62

${tl_scf_filename}   scf_5GC001576-BA_Topp.xml
${ru_index}        1

*** Keywords ***
5GC001250_Common Suite Setup for COAM
#    CI_interface.Common Suite Setup
    Set Suite Variable    ${TS_LOG_PATH_BASE}    ${tmp_log_dir}
    5GC001250_COAM Create log directory    is_set_to_test_case_level=${False}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}
    Create directory    ${epc_log_path}
    Admin Get MrbtsId And NrbtsId

5GC001250_Common Suite Teardown for COAM
    Run Keyword And Ignore Error    AdminCli disconnection and Test teardown

5GC001250_Generate suite log path
    [Arguments]    ${timeout}=1min
    ${ts_name}=    Replace String    string=${SUITE NAME}    search_for=${SPACE}    replace_with=_
    wait until keyword succeeds    ${timeout}    2sec    Connect to DU via ssl
    ${sw_version} =     coam.get_sw_version    connection=${connection}
    ${suite_log_path}    Join path    ${TS_LOG_PATH_BASE}    ${sw_version}    TS_${ts_name}
    Set Suite Variable    ${SUITE_LOG_PATH}    ${suite_log_path}
    Create directory    ${SUITE_LOG_PATH}

5GC001250_COAM Create log directory
    [Arguments]  ${is_set_to_test_case_level}=${True}    ${timeout}=1min
    5GC001250_Generate suite log path    timeout=${timeout}
    Run keyword if  ${is_set_to_test_case_level}
    ...    Run keywords    Generate test case log path    AND
    ...    Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
    ...    ELSE    Set suite variable    ${LOG_PATH}    ${SUITE_LOG_PATH}

Connect to DU via ssl
    [Arguments]  ${connection}=${connection}     ${bts_host}=${DU_OAM_IP}
    ...    ${username}=${WEBUI_USER}
    ...    ${password}=${WEBUI_PASSWORD}
    coam.connect_to    bts_host=${bts_host}    bts_port=${443}    username=${username}    password=${password}
    ...   name=${connection}

Precondition: All cells can be on air
    log to console  \n***** Precondition: All cells can be on air *****
    Check If BTS Is OnAir

AdminCli disconnection and Test teardown
    [Documentation]
    ...     Disconnects connection to gNB ADMIN and collect snapshot if any TC failed
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    admin_cli.teardown    connection=${connection}

Admin Get MrbtsId And NrbtsId
    run keyword and ignore error    admin_cli.Teardown
    admin_cli.get_current_scf_file    local_dir_path=${epc_log_path}    file_name=${scf_name}    connection=${connection}
    ${commission_file}    set variable    ${epc_log_path}/${scf_name}
    ${mrbtsId}    lib.Get_MRBTSID_cOAM    scf_path=${commission_file}
    ${nrbtsId}    lib.Get_NRBTSID_cOAM    scf_path=${commission_file}
    ${BTS_NAME}   lib.Get_BTS_name    scf_path=${commission_file}
    Set Suite Variable     ${mrbtsId}
    Set Suite Variable     ${nrbtsId}
    Set Suite Variable     ${dist_name}    MRBTS-${mrbtsId}/NRBTS-${nrbtsId}
    Set Suite Variable     ${commission_file}
    Set Suite Variable     ${BTS_NAME}

Check If BTS Is OnAir
    ${bts_statuses_response}=    admin_cli.Get Bts Info    connection=${connection}
    ${actual_value}=    Get From Dictionary
    ...    dictionary=${bts_statuses_response['status']}
    ...    key=proceduralState
    Should Be Equal
    ...    first=${actual_value}
    ...    second=OnAir

Connect to cOAM as toor4nsn
    [Arguments]    ${alias}=${connection}
    csn.Connect To    hostname=${DU_OAM_IP}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=${alias}

Disconnect from cOAM
    [Arguments]  ${connection}=cOAM_serviceuser
    ssh.disconnect  connection=${connection}

Case Setup
    Log To Console    \n *** Case Setup
    Precondition: All cells can be on air

Case teardown for case1
    Log To Console    \n *** Case Teardown
    Restore TOPP IP
    ${status}=    wait until keyword succeeds     10min    1min    Run Keyword And Return Status
    ...    Check fault Cancelled on WebEM    alarm_filter=${alarm_filter1}
    Run keyword if    ${status}==True    no operation
    ...    ELSE    run keyword    Du Reset
    Log To Console    \n *** DU will be reset if needed
    Wait until keyword succeeds     5min    1min    Check Cell Status Should Be Online
    Check Fault 4298 not raise on WebEM
    Run Keyword And Ignore Error    run keyword if test failed    Disconnect from cOAM
    Run Keyword And Ignore Error    siso_resource.WEBUI Logout
    CI_interface.Common Case Teardown

Case Teardown for case2
    Log To Console    \n *** Case Teardown
    Restore TOPP IP
    Run Keyword And Ignore Error    run keyword if test failed    Disconnect from cOAM
    Run Keyword And Ignore Error    siso_resource.WEBUI Logout
    CI_interface.Common Case Teardown

Case Teardown for case3
    Log To Console    \n *** Case Teardown
    Cancel fault 10 in WebEM
    Run Keyword And Ignore Error    run keyword if test failed    Disconnect from cOAM
    Run Keyword And Ignore Error    siso_resource.WEBUI Logout
    CI_interface.Common Case Teardown

Case Teardown for case4
    Log To Console    \n *** Case Teardown
#    Get parameter 'gscn' value
#    Set test variable    ${gscn_value_current}    ${gscn['gscnOrSsPbchArfcn']}
#    Run keyword if    ${gscn_value_current}!=${gscn_value}
#    ...    Parameter revert and check Cell status
#    ...    ELSE    Check all cell status
#    Run Keyword And Ignore Error    run keyword if test failed    Disconnect from cOAM
#    Run Keyword And Ignore Error    siso_resource.WEBUI Logout
    CI_interface.Common Case Teardown

Parameter revert and check Cell status
    Run keyword and continue on failure    Admin Lock all Cells
    Set test variable    ${gscn_expected}    ${gscn_value}
    Change the parameter 'gscn'
    Run keyword and continue on failure    Admin Unlock all Cells
    ${status2}=    Wait until keyword succeeds     5min    20s    Run Keyword And Return Status
    ...    Check fault Cancelled on WebEM    alarm_filter=7516
    Run keyword if    ${status2}==True    no operation
    ...    ELSE    run keywords    Admin Lock all Cells    AND    Admin Unlock all Cells

Case Teardown for case5
    Log To Console    \n *** Case Teardown
    Trigger Fault 61524 Raise
    Run Keyword And Ignore Error    run keyword if test failed    Disconnect from cOAM
    Run Keyword And Ignore Error    siso_resource.WEBUI Logout
    CI_interface.Common Case Teardown

Check all cell status
    [Arguments]         ${connection}=DU_OAM
    FOR  ${dist_name}    IN   @{dist_name_list}
        wait until keyword succeeds  180s  3s  Admin Check Parameters for Unlocked Cell
        ...                                   dist_name=${dist_name}  connection=${connection}
    END
###################################################################
Perform Parameter Update
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${value}
    ...            ${operation}
    ...            ${connection}=${connection}
    ...            ${skip_parameter_relation_errors}=True
    admin_cli.Perform Parameter Recommissioning
    ...    dist_name=${dist_name}
    ...    parameter=${parameter}
    ...    value=${value}
    ...    operation=${operation}
    ...    skip_parameter_relation_errors=True
    ...    connection=${connection}

Recored Current Active Alarm
    @{alarm_list_details}    admin_cli.get_active_alarms    connection=${connection}
    ${alarm_length}    admin_cli.get_active_alarms_number    connection=${connection}
    @{alarm_ID_list}    Create List
    FOR    ${alarm}    IN    @{alarm_list_details}
        Append To List    ${alarm_ID_list}    ${alarm["alarmId"]}
    END
    set suite variable    @{alarm_ID_list}
    set suite variable    ${alarm_length}

Check No New Active Alarm Exist
    ${current_alarm_length}    admin_cli.get_active_alarms_number    connection=${connection}
    @{current_alarm_list_details}    admin_cli.get_active_alarms    connection=${connection}
    FOR    ${alarm}    IN    @{current_alarm_list_details}
        Should be true    ${alarm["alarmId"]} in ${alarm_ID_list}
    END

Store Current Alarm in a file
    ${value}    Run Keyword And Ignore error    selenium_coam.save_current_alarms
    Run Keyword If   '${value[0]}'=='PASS'    Should Be True    ${value[1].count("${BTS_NAME}")} > 0

Store History Alarm in a file
    ${value}    Run Keyword And Ignore error    selenium_coam.save_historical_alarms
    Run Keyword If   '${value[0]}'=='PASS'    Should Be True    ${value[1].count("${BTS_NAME}")} > 0

Brower Current Alarm in a file
    ${value}    Run Keyword And Ignore error    selenium_coam.get_active_alarm_info
    ${alarm}    Run Keyword And Ignore error    Get From Dictionary    ${value[1]}[0]    Alarming object

Brower History Alarm in a file
    ${value}    Run Keyword And Ignore error    selenium_coam.get_history_alarm_info
    ${alarm}    Run Keyword And Ignore error    Get From Dictionary    ${value[1]}[0]    Alarming object

Check fault Cancelled on WebEM
    [Arguments]    ${alarm_filter}
    wait until keyword succeeds    3min    1min    siso_resource.WEBUI Login
    @{alarm info}=    selenium_coam.get_active_alarm_info    alarm_filter=${alarm_filter}    timeout=60
    should be empty    ${alarm_info}
    run keyword and ignore error    selenium_coam.logout

Du Reset
    [Arguments]    ${timeout}=300
    ...            ${wait_for_reconnection}=${True}
    ...            ${connection}=${connection}
    admin_cli.Reset Site
    ...    timeout=${timeout}
    ...    wait_for_reconnection=${wait_for_reconnection}
    ...    connection=${connection}

Get parameter value
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${timeout}=10
    ...            ${connection}=${connection}
    ${out_parameters}    admin_cli.get_parameters
    ...    dist_name=${dist_name}
    ...    pattern=${parameter}
    ...    timeout=${timeout}
    ...    connection=${connection}
    [Return]    ${out_parameters}


Add Toggling MO in SCF
        @{payload_list}    create list
        ${payload}=    create dictionary
        ...            alToggAmount=2
        ...            alToggClearenceTime=1200
        ...            alToggConditonTime=1800
        ...            faultName=FCT_4298_ToP reference missing
        ...            inUse=true
        @{payload_list}    create list    ${payload}
        ${dict}=    create dictionary               parameterName=alToggSuppList
        ...                                         operation=update
        ...                                         value=@{payload_list}

        @{parameter_list}   create list    ${dict}
        admin_cli.perform_object_recommissioning
        ...           dist_name=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FMCADM-1
        ...           parameter=@{parameter_list}
        ...           operation=update
        ...           skip_parameter_relation_errors=${True}
        ...           should_activate=${True}
        ...           connection=${connection}

Modidfy Parameter
        [Arguments]    ${ip_address}
        @{payload_list}    create list
        ${payload}=    create dictionary
        ...            localPriority=128
        ...            masterIpAddr=${ip_address}
        ...            maximumNetworkTimingError=0
        ...            phaseErrorComp=0
        ...            topMasterId=1
        append to list   ${payload_list}   ${payload}
        ${dict}=    create dictionary               parameterName=topMasterList
        ...                                         operation=update
        ...                                         value=@{payload_list}

        @{parameter_list}   create list    ${dict}
        admin_cli.perform_object_recommissioning
        ...           dist_name=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1
        ...           parameter=@{parameter_list}
        ...           operation=update
        ...           skip_parameter_relation_errors=${True}
        ...           should_activate=${True}
        ...           connection=${connection}

Check Fault 4298
    Check active fault on WebUI
    ...    alarm_filter=ToP reference missing
    ...    Severity_expect=major
    ...    AlarmID_expect=7108
    ...    AlarmName_expect=BASE STATION SYNCHRONIZATION PROBLEM
    ...    FaultID_expect=4298
    ...    FaultName_expect=ToP reference missing
    ...    AlarmOB_expect=[${BTS_NAME}]MRBTS-${mrbtsId}/EQM-1/APEQM-1/CABINET-1/SMOD-1

Check Fault 4026
    Check active fault on WebUI
    ...    alarm_filter=Toggling: ToP reference missing (4298)
    ...    Severity_expect=major
    ...    AlarmID_expect=7108
    ...    AlarmName_expect=BASE STATION SYNCHRONIZATION PROBLEM
    ...    FaultID_expect=4026
    ...    FaultName_expect=Toggling: ToP reference missing (4298)
    ...    AlarmOB_expect=[${BTS_NAME}]MRBTS-${mrbtsId}/EQM-1/APEQM-1/CABINET-1/SMOD-1

#--------------------5GC001250-BA_5GC000167_001/004----------------------------------------------
Add Toggling MO
    Log    \nAdd Toggling MO   console=yes
    Add Toggling MO in SCF

Configure invalid TOPP IP
    Log    \nConfigure invalid TOPP IP    console=yes
    Modidfy Parameter     ip_address=${invalid_ip}

Check Fault 4298 in WebEM
    Log    \nCheck Fault 4298 in WebEM    console=yes
    Wait until keyword succeeds    3min    1min    siso_resource.WEBUI Login
    Wait until keyword succeeds     10min    2min    Check Fault 4298
    Run keyword and ignore error    siso_resource.WEBUI Logout

Restore TOPP IP
    Log    \nRestore TOPP IP   console=yes
    Modidfy Parameter     ip_address=${valid_ip}

Check Fault 4298 cancelled on WebEM
    Log    \nCheck Fault 4298 cancelled on WebEM   console=yes
    Wait until keyword succeeds     25min    5min    Check fault Cancelled on WebEM    alarm_filter=${alarm_filter1}
    Wait until keyword succeeds     5min    1min    Check Cell Status Should Be Online

Check Fault 4298 not raise on WebEM
    Log    \nCheck Fault 4298 not raise on WebEM   console=yes
    Wait until keyword succeeds     10min    2min    Check fault Cancelled on WebEM    alarm_filter=[4298]

Check Fault 4026 in WebEM
    Log    \nCheck Fault 4026 in WebEM    console=yes
    Wait until keyword succeeds    3min    1min    siso_resource.WEBUI Login
    Wait until keyword succeeds     20min    3min    Check Fault 4026
    Run keyword and ignore error    siso_resource.WEBUI Logout

Check Fault 4026 cancelled on WebEM
    Log    \nCheck Fault 4026 cancelled on WebEM   console=yes
    Wait until keyword succeeds     30min    5min    Check fault Cancelled on WebEM    alarm_filter=${alarm_filter2}

Check Cell Status Should Be Online
    Log    \nCheck Cell Status Should Be Online    console=yes
    ${result_cell}    admin_cli.get_cells_info    connection=DU_OAM
    ${availability_status}=   set variable  ${result_cell[0]['status']['availabilityStatus']}
	Run keyword and continue on failure
    ...    should be equal as strings     ${availability_status}    Online

Check fault 4298 in the History Alarm File
    Log    \nCheck fault 4298 in the History Alarm File    console=yes
    Perform Parameter Update
    ...    dist_name=MRBTS-${mrbtsId}/MNL-1/MNLENT-1/SECADM-1
    ...    parameter=actServiceAccountSsh
    ...    operation=update
    ...    value=true
    ...    skip_parameter_relation_errors=True
    Connect to cOAM as toor4nsn    alias=gNB
    csn.send command        command=chmod 777 /tmp/RawAlarmHistory.txt      connection=gNB
    csn.download_file   remote_path=/tmp/RawAlarmHistory.txt   local_path=/home/ute/logs/RawAlarmHistory.txt
    ...    connection=gNB
    sleep   30s
    ${res}=    Grep File  path=/home/ute/logs/RawAlarmHistory.txt    pattern=4298
    Run keyword and continue on failure    Should Contain    ${res}     EFaultId_TopRefMissAl
    Run keyword and ignore error  csn.disconnect    connection=gNB

Check Fault cancelled on WebEM with cell status restored
       Log    \nCheck Fault cancelled on WebEM with cell status restored   console=yes
       wait until keyword succeeds     10min    1min    Check fault Cancelled on WebEM    alarm_filter=${alarm_filter1}
       Check Cell Status Should Be Online

#--------------------5GC001250-CA_5GC000169_001----------------------------------------------
Trigger Fault 10 Raise
    Log    \nTrigger Fault 10 Raise    console=yes
    Perform RU Power Off    ru_index=${ru_index}

Check Fault 10 in WebEM
    Log    \nCheck Fault 10 in WebEM    console=yes
    wait until keyword succeeds    3min    1min    siso_resource.WEBUI Login
    wait until keyword succeeds     5min    1min    Check active fault on WebUI
    ...    alarm_filter=${alarm_filter_10}
    ...    Severity_expect=critical
    ...    AlarmID_expect=7116
    ...    AlarmName_expect=BASE STATION SERVICE PROBLEM
    ...    FaultID_expect=10
    ...    FaultName_expect=${alarm_filter_10}
    ...    AlarmOB_expect=[${BTS_NAME}]MRBTS-${mrbtsId}/EQM-1/APEQM-1/RMOD-1
    run keyword and ignore error    selenium_coam.logout

Check No Other Fault Raise
    Log    \nCheck No Other Fault Raise    console=yes
    Recored Current Active Alarm
    Check No New Active Alarm Exist

Browse and Store Current Alarm in a file
    Log    \nBrowse and Store Current Alarm in a file    console=yes
    Brower Current Alarm in a file
    Store Current Alarm in a file

Cancel fault 10 in WebEM
    Log    \nCancel fault 10 and check on WebEM   console=yes
    Perform RU Power On    ru_index=${ru_index}
    wait until keyword succeeds     10min    2min    Check fault Cancelled on WebEM    alarm_filter=${alarm_filter_10}

Browse and Store History Alarm in a file
    Log    \nBrowse and Store History Alarm in a file    console=yes
    Brower History Alarm in a file
    Store History Alarm in a file

#--------------------5GC001250-CA_5GC000169_004----------------------------------------------
Trigger Fault 7516
    Log    \nTrigger Fault 7516    console=yes
    Get parameter 'gscn' value
    Set test variable    ${gscn_value}    ${gscn['gscnOrSsPbchArfcn']}
    ${gscn_mod1}    evaluate    ${gscn_value}+50
    Set test variable    ${gscn_new}    ${gscn_mod1}
    Set test variable    ${gscn_expected}    ${gscn_new}
    Change the parameter 'gscn'

Get parameter 'gscn' value
    ${get_managed_objects}    admin_cli.get_managed_objects    class_name=NRCELL_A    connection=${connection}
    ${gscn}    admin_cli.get_parameters    dist_name=${get_managed_objects[0]['distName']}
    ...    pattern=gscnOrSsPbchArfcn    connection=${connection}
    Set test variable    ${gscn}

Change the parameter 'gscn'
    admin_cli.perform_parameter_recommissioning   dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1
    ...   parameter=gscnOrSsPbchArfcn
    ...   value=${gscn_expected}
    ...   operation=update
    ...   skip_parameter_relation_errors=${true}
    ...   should_activate=${true}
    ...   timeout=60
    ...   connection=${connection}

Check Fault 7516 from DU WebEM
    Log    \nCheck Fault 7516 from DU WebEM    console=yes
    Wait until keyword succeeds    3min    1min    siso_resource.WEBUI Login
    Wait until keyword succeeds    5min    1min    Check active fault on WebUI
    ...    alarm_filter=7114
    ...    Severity_expect=critical
    ...    AlarmID_expect=7114
    ...    AlarmName_expect=CELL SERVICE PROBLEM
    ...    FaultID_expect=7516
    ...    FaultName_expect=Incorrect cell parameter configuration
    ...    AlarmOB_expect=[${BTS_NAME}]MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1
    Run keyword and ignore error    selenium_coam.logout

Check Fault 7516 Exist in RawAlarmsHistory.txt
    Log    \nCheck Fault 7516 Exist in RawAlarmsHistory.txt    console=yes
    Connect to cOAM as toor4nsn    alias=${connection}
    csn.send command        command=chmod 777 /tmp/RawAlarmHistory.txt      connection=${connection}
    csn.download_file   remote_path=/tmp/RawAlarmHistory.txt   local_path=/home/ute/logs/RawAlarmHistory.txt
    ...    connection=${connection}
    Sleep   30s
    ${res}=    Grep File  path=/home/ute/logs/RawAlarmHistory.txt    pattern=7516
    Run keyword and continue on failure    Should Contain    ${res}     EFaultId_IncorrectCellParameterSettingAl
    Run keyword and ignore error  csn.disconnect    connection=${connection}

Clear Fault 7516
    Log    \nClear Fault 7516   console=yes
    Run keyword and continue on failure    Admin Lock all Cells
    Set test variable    ${gscn_expected}    ${gscn_value}
    Change the parameter 'gscn'
    Run keyword and continue on failure    Admin Unlock all Cells
    ${status1}=    Wait until keyword succeeds     3min    30s    Run Keyword And Return Status
    ...    Check fault Cancelled on WebEM    alarm_filter=7516
    Run keyword if    ${status1}==True    no operation
    ...    ELSE    run keywords    Admin Lock all Cells    AND    Admin Unlock all Cells

Admin Lock all Cells
    [Arguments]         ${connection}=${connection}
    Admin Lock Cell    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1  connection=${connection}
    wait until keyword succeeds  10min  2min  Admin Check Parameters for Locked Cell
    ...      dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1  connection=${connection}
#    ${dist_name_list}=       get_admin_cells_mrbts        connection=${connection}
#    Set test variable     ${dist_name_list}
#    : FOR  ${dist_name}    IN   @{dist_name_list}
#    \  Admin Lock Cell    dist_name=${dist_name}  connection=${connection}
#    \  wait until keyword succeeds  10min  2min  Admin Check Parameters for Locked Cell
#        ...                                   dist_name=${dist_name}  connection=${connection}

Admin Unlock all Cells
    [Arguments]         ${connection}=${connection}
#    : FOR  ${dist_name}    IN   @{dist_name_list}
#    \  Admin Unlock Cell  dist_name=${dist_name}    connection=${connection}
#    \  wait until keyword succeeds  10min  2min  Admin Check Parameters for Unlocked Cell
#        ...                                   dist_name=${dist_name}  connection=${connection}
    Admin Unlock Cell  dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1    connection=${connection}
    wait until keyword succeeds  10min  2min  Admin Check Parameters for Unlocked Cell
    ...   dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1  connection=${connection}

Admin Lock Cell
    [Arguments]  ${dist_name}
    ...          ${connection}=DU_OAM
    ${status}  admin_cli.lock_cell  dist_name=${dist_name}       connection=${connection}
    Should be equal as strings   ${status}      completed

Admin Unlock Cell
    [Arguments]  ${dist_name}
    ...          ${connection}=DU_OAM
    ${status}  admin_cli.unlock_cell  dist_name=${dist_name}       connection=${connection}
    Should be equal as strings   ${status}      completed

Check Fault 7516 Cancelled from WebEM
    Log    \nCheck Fault 7516 Cancelled from WebEM  console=yes
    Wait until keyword succeeds     20min    1min    Check fault Cancelled on WebEM    alarm_filter=7516

Admin Check Parameters for Locked Cell
    [Arguments]  ${dist_name}
    ...          ${connection}=DU_OAM
    ${cell_status}=    admin_cli.get_cell_specific_info  cell_id=${dist_name}  connection=${connection}
    Should be equal as strings  ${cell_status['status']['operationalState']}     Disabled
    Should be equal as strings  ${cell_status['status']['availabilityStatus']}   Offline
    Should be equal as strings  ${cell_status['status']['administrativeState']}  Locked

Admin Check Parameters for Unlocked Cell
    [Arguments]  ${dist_name}
    ...          ${connection}=DU_OAM
    ${cell_status}=    admin_cli.get_cell_specific_info  cell_id=${dist_name}        connection=${connection}
    Should be equal as strings  ${cell_status['status']['operationalState']}     Enabled
    Should be equal as strings  ${cell_status['status']['availabilityStatus']}   Online
    Should be equal as strings  ${cell_status['status']['administrativeState']}  Unlocked

#--------------------5GC001250-EA_5GC000169_005----------------------------------------------
Trigger Fault 61524 Raise
    Log    \nTrigger Fault 61524 Raise    console=yes
    Perform Parameter Update
    ...    dist_name=MRBTS-${mrbtsId}/MNL-1/MNLENT-1/SECADM-1
    ...    parameter=actServiceAccountSsh
    ...    operation=update
    ...    value=true
    ...    skip_parameter_relation_errors=True

Check Fault 61524 in WebEM
    Log    \nCheck Fault 61524 in WebEM    console=yes
    Wait Until Keyword Succeeds      3min   1min    siso_resource.WEBUI Login
    wait until keyword succeeds     5min    1min    Check active fault on WebUI
    ...    alarm_filter=${alarm_filter_05}
    ...    Severity_expect=minor
    ...    AlarmID_expect=7220
    ...    AlarmName_expect=BASE STATION SECURITY PROBLEM
    ...    FaultID_expect=61524
    ...    FaultName_expect=${alarm_filter_05}
    ...    AlarmOB_expect=[${BTS_NAME}]MRBTS-${mrbtsId}/EQM-1/APEQM-1/CABINET-1/SMOD-1
    run keyword and ignore error    selenium_coam.logout

Cancel fault 61524 in WebEM
    Log    \nCancel fault 61524 and check on WebEM   console=yes
    Perform Parameter Update
    ...    dist_name=MRBTS-${mrbtsId}/MNL-1/MNLENT-1/SECADM-1
    ...    parameter=actServiceAccountSsh
    ...    operation=update
    ...    value=false
    ...    skip_parameter_relation_errors=True
    Check fault Cancelled on WebEM    alarm_filter=${alarm_filter_05}
