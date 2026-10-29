*** Settings ***
Documentation
...   author: Mansour Medini
...   contact: mansour.medini@nokia.com


Library     taf.sbts.oam.coam.admin   WITH NAME   coam
Library     taf.transport.ssh    WITH NAME    csn
Library     OperatingSystem
Library     Collections
Library     BuiltIn
Library 	DateTime
Library 	String
Library     XML  lxml=True
Library    	parse.py
Resource    variables.robot
Variables    variables.py


*** Variables ***

*** Keywords ***

5GC000551_CLASSICAL Setup
    Run  pkill -f admin
    Run  pkill -f geckodriver
    Run  pkill -f firefox
    Run  pkill -f gvfsd-metadata

5GC000551_CLASSICAL Teardown
    wait until keyword succeeds     5min    30s
	...      coam.connect to   bts_host=${WEBUI_URL}   name=coam_admin
    login to WEBEM selenium coam
    Set mrbtsId variable
    Delete faultSnapshotTriggers Element
    Reload webpage and logout
    coamteardown
    
Create a File
	${day} =   				Get Current Date   	result_format=%Y_%m_%d 
	${hour} =   			Get Current Date   	result_format=%H_%M_%S
	${date} =   			Get Current Date
	${datetime} =			Convert Date		${date}		datetime
	set global variable     ${day}
	set global variable  	${hour}
    create directory        ${LOG_PATH}
    run     rm -rf ${LOG_PATH}/*.*
    Create File          	${LOG_PATH}/Snaps_logs.txt

Save Snapshot for cOAM to Local
    [Documentation]   This keyword is used to Save Snapshot for cOAM to Local.
    [Arguments]    ${coverage}
    Log to console    Save Snapshot for cOAM to Local
    wait until keyword succeeds     5min    30s
    ...      coam.connect to   bts_host=${WEBUI_URL}   name=coam_admin
    ${sw_d}=      coam.get_sw_version     connection=coam_admin
    Set Suite Variable    ${sw_d}
    ${day} =   			Get Current Date   	result_format=%Y_%m_%d 
	${hour} =   			Get Current Date   	result_format=%H_%M_%S
    ${snapshot_path}=    set variable  ${LOG_PATH}/Snapshot_${TL_ID}_${sw_d}_${day}_${hour}.zip
    Set Global Variable    ${snapshot_path}
    coam.get_snapshot     target_file_name=${snapshot_path}		coverage=${coverage}    timeout=1200
    ...      connection=coam_admin
    OperatingSystem.File Should Exist    ${snapshot_path}
    OperatingSystem.File Should Not Be Empty    ${snapshot_path}
    coam.teardown    connection=coam_admin
    sleep    60s

Save Snapshot for cOAM to Netact
    [Documentation]   This keyword is used to Save Snapshot for cOAM to Netact CFAM 1544.
    [Arguments]    ${coverage}
    Log to console    Save Snapshot for cOAM to Netact
    wait until keyword succeeds     5min    30s
    ...      coam.connect to   bts_host=${WEBUI_URL}   name=coam_admin
    ${KPI_BEGIN}=    Get Current Date
	Set Global Variable    ${KPI_BEGIN}
    coam.get_remote_snapshot     coverage=${coverage}		timeout=1200      connection=coam_admin
	${KPI_END}=    Get Current Date
	Set Global Variable    ${KPI_END}
	Calcul KPI
    ${Snapshot_status}=		Set Variable    PASS
    Set Global Variable		${Snapshot_status}
    coam.teardown    connection=coam_admin
    sleep    60s
    
Connect to Netact server Snapshot
    [Documentation]   This keyword is used to Connect to Netact server Snapshot and GET Snapshot list of the TL
    Log to console                  Connect to Netact server Snapshot
    csn.Connect to     ${tl_na_vm16_address}     ${tl_na_omc_user}     ${tl_na_omc_password}    alias=Netact
    ${Snapshot_file}=    csn.execute
    ...     find /d/oss/global/diagsnap/ne3sws/ -name "*_${TL_ID}_*.zip" -size +11c -exec ls -t "{}" + | head -1;
    ...    connection=Netact
    ${Snapshot_file_clean}=    strip_character_newline		${Snapshot_file}
    Append To File      ${LOG_PATH}/Snaps_logs.txt       ${Snapshot_file_clean}
    Append To File      ${LOG_PATH}/Snaps_logs.txt       /${KPI_DURATION}second\n


Calcul KPI
    [Documentation]   This keyword is used to Calculate KPI Snapshot duration to Netact
    ${KPI_DURATION}  Run Keyword If  '${KPI_END}' != '0'  Subtract Date From Date  ${KPI_END}  ${KPI_BEGIN}
    Set Global Variable  ${KPI_DURATION}

Retrieve Snapshot in Netact
    [Documentation]   This keyword is used to retrieve Snapshot in Netact 
	${list_SNAP_files}=     get_file_name    ${LOG_PATH}/Snaps_logs.txt
	should not be empty    ${list_SNAP_files}
	Get All List of Snapshot files and Download files     LIST=${list_SNAP_files}

Get All List of Snapshot files and Download files
    [Documentation]   This keyword is used to Get All List of Snapshot files and Download files
	[Arguments]    ${LIST}
    create directory     ${LOG_PATH}/SNAP_FILES
    run     rm -rf ${LOG_PATH}/SNAP_FILES/*.*
    FOR    ${value}    IN  @{LIST}
       log     ${value}
       Run keyword and continue on failure     csn.Download File   /d/oss/global/diagsnap/ne3sws/${value}
    ...    ${LOG_PATH}/SNAP_FILES/${value}    connection=Netact
       ${file_size_SNAP}=		Get File Size    ${LOG_PATH}/SNAP_FILES/${value}
    	File Should Not Be Empty    ${LOG_PATH}/SNAP_FILES/${value}
    END


Copy Log Files
    Log to console                  Copy Log Files
    Move File       ${LOG_PATH}/Snaps_logs.txt        ${LOG_PATH}/Snapshot_logs_${day}_H_${hour}.txt

Fault Should Be Present
    [Documentation]
    [Arguments]    ${fault_id}
    Log To Console    KW - Fault Should Be Present fault_id=${fault_id}
    ${active_alarms}    coam.get_active_alarms    timeout=60    connection=coam_admin
    ${len}    Get Length    ${active_alarms}
    ${alarm_id_list}    Create List
    FOR    ${i}    IN RANGE    ${len}
        ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    faultId
        Append To List    ${alarm_id_list}    ${tmp_id}
    END
    Log To Console    Active alarms: alarm_id_list=${alarm_id_list}
    ${list}     convert to string  ${alarm_id_list}
    Should Contain     ${list}    ${fault_id}

Alarm Should Be Present
    [Documentation]
    [Arguments]    ${alarm_id}
    Log To Console    KW - Alarm Should Be Present alarm_id=${alarm_id}
    ${active_alarms}    coam.get_active_alarms    timeout=60    connection=coam_admin
    ${len}    Get Length    ${active_alarms}
    ${alarm_id_list}    Create List
    FOR    ${i}    IN RANGE    ${len}
        ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    alarmId
        Append To List    ${alarm_id_list}    ${tmp_id}
    END
    Log To Console    Active alarms: alarm_id_list=${alarm_id_list}
    ${list}     convert to string  ${alarm_id_list}
    Should Contain   ${list}    ${alarm_id}

Fault Should Not Be Present
    [Documentation]
    [Arguments]    ${fault_id}
    Log To Console    KW - Fault Should Not Be Present fault_id=${fault_id}
    ${active_alarms}    coam.get_active_alarms    timeout=60    connection=coam_admin
    ${len}    Get Length    ${active_alarms}
    ${alarm_id_list}    Create List
    FOR    ${i}    IN RANGE    ${len}
        ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    faultId
        Append To List    ${alarm_id_list}    ${tmp_id}
    END
    Log To Console    Active alarms: alarm_id_list=${alarm_id_list}
    ${list}     convert to string  ${alarm_id_list}
    Should Not Contain     ${list}    ${fault_id}

Alarm Should Not Be Present
    [Documentation]
    [Arguments]    ${alarm_id}
    Log To Console    KW - Alarm Should Not Be Present alarm_id=${alarm_id}
    ${active_alarms}    coam.get_active_alarms    timeout=60    connection=coam_admin
    ${len}    Get Length    ${active_alarms}
    ${alarm_id_list}    Create List
    FOR    ${i}    IN RANGE    ${len}
        ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    alarmId
        Append To List    ${alarm_id_list}    ${tmp_id}
    END
    Log To Console    Active alarms: alarm_id_list=${alarm_id_list}
    ${list}     convert to string  ${alarm_id_list}
    Should Not Contain   ${list}    ${alarm_id}

Fault Should Be Present in WebEM
  [Arguments]    ${fault_id}
  ${active_alarms}    coam.get_active_alarms    timeout=60    connection=coam_admin
  ${len}    Get Length    ${active_alarms}
  ${alarm_id_list}    Create List
  FOR    ${i}    IN RANGE    ${len}
      ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    faultId
      Append To List    ${alarm_id_list}    ${tmp_id}
  END
  ${list}     convert to string  ${alarm_id_list}
  Should Contain     ${list}    ${fault_id}

Fault Should Not Be Present in WebEM
  [Arguments]    ${fault_id}
  ${active_alarms}    coam.get_active_alarms    timeout=60    connection=coam_admin
  ${len}    Get Length    ${active_alarms}
  ${alarm_id_list}    Create List
  FOR    ${i}    IN RANGE    ${len}
      ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    faultId
      Append To List    ${alarm_id_list}    ${tmp_id}
  END
  ${list}     convert to string  ${alarm_id_list}
  Should Not Contain     ${list}    ${fault_id}

Wait For Fault to appear in WebEM
  [Arguments]  ${FaultID}
  wait until keyword succeeds  300s      1s    Fault Should Be Present in WebEM   ${FaultID}

Wait For Fault to disappear in WebEM
  [Arguments]  ${FaultID}
  wait until keyword succeeds  300s      1s    Fault Should Not Be Present in WebEM   ${FaultID}

coamteardown
	coam.teardown    connection=coam_admin

Get SW version
	wait until keyword succeeds     5min    30s
	...      coam.connect to   bts_host=${WEBUI_URL}   name=coam_admin
	${current_sw_version}  coam.get_sw_version  timeout=10  connection=coam_admin
	Set Global Variable  ${current_sw_version}
	coam.teardown  connection=coam_admin

Check number of snapshot on NetAct
	csn.Connect To  hostname=${tl_na_vm16_address}  username=${tl_na_omc_user}  password=${tl_na_omc_password}
	...  alias=NETACT_VM16  timeout=5
	csn.Execute  ls -rtl /d/oss/global/diagsnap/ne3sws/*_${TL_ID}_*  connection=NETACT_VM16
	${TEST_STEP}  csn.Execute  ls -rtl /d/oss/global/diagsnap/ne3sws/*_${TL_ID}_* | wc -l
	...  connection=NETACT_VM16
	Set Global Variable  ${TEST_STEP}
        ${num_before}         Set Variable    ${TEST_STEP.split("\r\n")[0]}       
	Log    ${TEST_STEP.split("\r\n")[0]}
	Run keyword If        'No' in '${num_before}'    Set Global Variable    ${TEST_STEP.split("\r\n")[0]}    0
	csn.Disconnect  connection=NETACT_VM16

Check if Snapshot is colleted
    Check number of snapshot on NetAct
    Should Be Equal As Integers  ${snapshot_TARGET}  ${TEST_STEP.split("\r\n")[0]}

login to WEBEM selenium coam
    [Documentation]    This keyword is used login to WEBEM in selenium_coam
    Log to console    login to WEBEM in selenium_coam
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${WEBUI_URL}
    ...                    username=${WEBUI_USER}
    ...                    password=${WEBUI_PASSWORD}
    ...                    download_dir=${download_dir}
    selenium_coam.disable_message_box

Reload webpage and logout
    selenium_coam.continue_after_reload_modal_appear
    selenium_coam.logout

Set mrbtsId variable
    coam.collect scf   target_file_name=${LOG_PATH}/scf.xml    connection=coam_admin
    ${XML}=   Parse XML   ${LOG_PATH}/scf.xml
    ${mrbtsId_element}=   Get Element   ${XML}   .//managedObject[@class="com.nokia.srbts:MRBTS"]
    set global variable   ${mrbtsId}   ${mrbtsId_element.attrib['distName']}

Fault snapshot triggers parameter creation
    log to console    Add Fault snapshot triggers parameter creation - Fault 61649
    #selenium_coam.add_element    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    # ...    filter_param=Fault snapshot triggers      timeout=${100}
    sleep    2s
    selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault number         new_value=${61649}
    ...    node_index=${0}    timeout=${100}
    sleep    2s
    selenium_coam.set_parameter_value    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Trigger type      new_value=onFaultDetection    node_index=${0}    timeout=${100}
    sleep    2s
    Validate and activate and check activate plan status
#    ${output}    Run Keyword And Ignore Error    selenium_coam.add_element
#    ...    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
#    ...    filter_param=Fault snapshot triggers    timeout=${100}
#    log    ${output}

Validate and activate and check activate plan status
    selenium_coam.validate_plan
    sleep    5s
    #selenium_coam.activate_plan    activate_plan_despite_errors=True
    selenium_coam.activate_plan
    #sleep    10s
    #selenium_coam.check_activate_plan_status
    sleep    5s

Delete faultSnapshotTriggers Element
    selenium_coam.delete_parameter    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault snapshot triggers       timeout=${100}
    Validate and activate and check activate plan status
    



