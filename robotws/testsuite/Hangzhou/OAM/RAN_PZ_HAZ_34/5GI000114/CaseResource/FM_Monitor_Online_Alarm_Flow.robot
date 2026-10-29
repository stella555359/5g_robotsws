*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   ../Resource/NetAct_Fast_Pass_common.robot

*** Variables ***

*** Keywords ***
FM Monitor Online Alarm Flow
    Step1 Open Monitor and Reset Workspace
    Step2 Open alarm list
    Step3 Create Minor Major and Critical alarms for NE and check them on Monitor
    Step4 Acknowledge all these alarms
    Step5 Create View and drop NE to the View
    Step6 Check Alarms was Cleared on Alarm List
    Step7 Check If Alarms Exist In NE Alarm History

Case Setup: FM Monitor Online Alarm Flow
    Run Keyword If   '${release.find('CLA')}'!='-1' or '${release.find('SBTS')}'!='-1'
    ...   Set Test Variable   ${CLASSICAL}  ${True}  ELSE  Set Test Variable  ${CLASSICAL}  ${False}
    Run Keyword If   '${release.find('CU')}'!='-1'   Set Test Variable   ${CLOUDCU}   ${True}   ELSE   Set Test Variable   ${CLOUDCU}   ${False}
    Run Keyword If   '${release.find('DU')}'!='-1'   Set Test Variable   ${CLOUDDU}   ${True}   ELSE   Set Test Variable   ${CLOUDDU}   ${False}
    Run Keyword And Ignore Error   Cancel All Alarms
    Open Netact Start Page   url=${START_PAGE}    username=${START_PAGE_USER}    password=${START_PAGE_PASSWORD}

Case Teardown: FM Monitor Online Alarm Flow
    Run Keyword And Ignore Error   Delete View Folder   view_folder_name=${VIEW_FOLDER_NAME}
    Run Keyword And Ignore Error   Cancel All Alarms
    Run Keyword And Ignore Error   Run Keyword If   ${CLASSICAL} or ${CLOUDDU}
    ...   COAM Update Parameter ON COAM ADMIN
    ...   dist_name=${MO_NAME}/MNL-1/MNLENT-1/SECADM-1
    ...   parameter=actServiceAccountSsh
    ...   value=true
    Run Keyword And Ignore Error   selenium_netact.Logout
    Run Keyword And Ignore Error   selenium_coam.Logout
    Run Keyword And Ignore Error   Close Java Application by Remote Port   remote_port=${REMOTE_PORT}
    Run Keyword And Ignore Error   Close All Java Application Forced
    run keyword if test failed  run keyword and ignore error   Catch Logs from NetAct   node_ip=${HOST_IP['${WAS_DMGR_HOSTS[0]}']}
    ...   username=${SERVICE_USER}   password=${SERVICE_PASSWORD}   Log_Area=FM
    run keyword if test failed  run keyword and ignore error   Catch Logs from NetAct   node_ip=${HOST_IP['${JBI_COMMONMEDIATION_HOSTS[0]}']}
    ...   username=${SERVICE_USER}    password=${SERVICE_PASSWORD}   Log_Area=COMMON_MEDIATION

Step1 Open Monitor and Reset Workspace
    ${REMOTE_PORT}   Open Monitor
    Set Test Variable  ${REMOTE_PORT}

Step2 Open alarm list
    Select MO and Open Popup Menu in FM Monitor   mo_name=PLMN-PLMN|${MO_NAME}   popup_menu=Find In|Alarm List
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    30s    2s    swing.Component Should Exist   identifier=${ALARM_LIST_COMPONENT}
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    1 min    5 sec
    ...   My Swing Table Row Count Should Be Stable   tableId=${ALARM_LIST_COMPONENT}   sleepTimeSeconds=8 sec

Step3 Create Minor Major and Critical alarms for NE and check them on Monitor
    Trigger All Alarms

    ${CRITICAL_ALARM_INFO}   Run Keyword If   ${CLOUDCU}
    ...   Create Dictionary   severity=Critical   alarmName=7108
    Run Keyword If   ${CLOUDCU}   Set Test Variable  ${CRITICAL_ALARM_INFO}
    ${MAJOR_ALARM_INFO}   Run Keyword If   ${CLOUDCU}
    ...   Create Dictionary   severity=Major   alarmName=7106
    Run Keyword If   ${CLOUDCU}   Set Test Variable  ${MAJOR_ALARM_INFO}
    ${MINOR_ALARM_INFO}   Run Keyword If   ${CLOUDCU}
    ...   Create Dictionary   severity=Minor   alarmName=7105
    ...   ELSE   create dictionary   severity=Minor   alarmName=7220
    ...   senderDN=PLMN-PLMN/${MO_NAME}/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1
    Set Test Variable  ${MINOR_ALARM_INFO}

    ${CRITICAL_ROW}   Run Keyword If   ${CLOUDCU}   Wait Until Keyword Succeeds   2min   10s
    ...   Find Alarm for MO in FM Monitor   table_name=${ALARM_LIST_COMPONENT}
    ...   search_key_dict=${CRITICAL_ALARM_INFO}   alarm_status=${true}
    Set Test Variable   ${CRITICAL_ROW}
    ${MAJOR_ROW}   Run Keyword If   ${CLOUDCU}   Wait Until Keyword Succeeds   2min   10s
    ...   Find Alarm for MO in FM Monitor   table_name=${ALARM_LIST_COMPONENT}
    ...   search_key_dict=${MAJOR_ALARM_INFO}   alarm_status=${true}
    Set Test Variable  ${MAJOR_ROW}
    ${Minor_ROW}   Wait Until Keyword Succeeds   2min   10s
    ...   Find Alarm for MO in FM Monitor   table_name=${ALARM_LIST_COMPONENT}
    ...   search_key_dict=${MINOR_ALARM_INFO}   alarm_status=${true}
    Set Test Variable  ${Minor_ROW}

Step4 Acknowledge all these alarms
    Run Keyword If   ${CLOUDCU}
    ...   Acknowledge Alarm From Alarm List   table_name=${ALARM_LIST_COMPONENT}   search_key_dict=${CRITICAL_ALARM_INFO}
    Run Keyword If   ${CLOUDCU}
    ...   Acknowledge Alarm From Alarm List   table_name=${ALARM_LIST_COMPONENT}   search_key_dict=${MAJOR_ALARM_INFO}
    Acknowledge Alarm From Alarm List   table_name=${ALARM_LIST_COMPONENT}   search_key_dict=${MINOR_ALARM_INFO}

Step5 Create View and drop NE to the View
    ${current_date}   Get Current Date
    ${date_str}   DateTime.Convert Date   ${current_date}   %Y%m%d%H%M
    ${VIEW_FOLDER_NAME}   set variable   folder${date_str}
    ${VIEW_NAME}   set variable   view${date_str}
    Set Test Variable   ${VIEW_FOLDER_NAME}
    Set Test Variable   ${VIEW_NAME}
    Create View Folder   folder_name=${VIEW_FOLDER_NAME}
    sleep   5s
    Create View   view_folder_name=${VIEW_FOLDER_NAME}   view_name=${VIEW_NAME}
    sleep   5s
    Copy NE to View   view_folder_name=${VIEW_FOLDER_NAME}   view_name=${VIEW_NAME}   DN=PLMN-PLMN|${MO_NAME}

Step6 Check Alarms was Cleared on Alarm List
    Cancel All Alarms
    Wait Until Keyword Succeeds   30s   10s   swing.Select From Main Menu And Wait   menuPath=Window|Reset Workspace
    sleep   5s
    Select MO and Open Popup Menu in FM Monitor   mo_name=PLMN-PLMN|${MO_NAME}   popup_menu=Find In|Alarm List
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    30s    2s    swing.Component Should Exist   identifier=${ALARM_LIST_COMPONENT}
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    1 min    5 sec
    ...   My Swing Table Row Count Should Be Stable   tableId=${ALARM_LIST_COMPONENT}   sleepTimeSeconds=8 sec
    Run Keyword If   ${CLOUDCU}
    ...   Wait Until Keyword Succeeds   2min   10s   Find Alarm for MO in FM Monitor
    ...   table_name=${ALARM_LIST_COMPONENT}   search_key_dict=${CRITICAL_ALARM_INFO}   alarm_status=${false}
    Run Keyword If   ${CLOUDCU}
    ...   Wait Until Keyword Succeeds   2min   10s   Find Alarm for MO in FM Monitor
    ...   table_name=${ALARM_LIST_COMPONENT}   search_key_dict=${MAJOR_ALARM_INFO}   alarm_status=${false}
    Wait Until Keyword Succeeds   2min   10s   Find Alarm for MO in FM Monitor
    ...   table_name=${ALARM_LIST_COMPONENT}   search_key_dict=${MINOR_ALARM_INFO}   alarm_status=${false}

Step7 Check If Alarms Exist In NE Alarm History
    Wait Until Keyword Succeeds   30s   10s   swing.Select From Main Menu And Wait   menuPath=Window|Reset Workspace
    sleep   5s
    Select MO and Open Popup Menu in FM Monitor   mo_name=PLMN-PLMN|${MO_NAME}   popup_menu=Find In|Alarm History
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    30s    2s    swing.Component Should Exist   identifier=${ALARM_LIST_COMPONENT}
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    1 min    5 sec
    ...   My Swing Table Row Count Should Be Stable   tableId=${ALARM_LIST_COMPONENT}   sleepTimeSeconds=8 sec
    Run Keyword If   ${CLASSICAL} or ${CLOUDDU}
    ...   Check If Alarm Exist In NE Alarm History   alarmNbr=7220   alarmSeverity=Minor
    ...   tableName=${ALARM_LIST_COMPONENT}   tableRow=${Minor_ROW}

    Run Keyword If   ${CLOUDCU}
    ...   Check If Alarm Exist In NE Alarm History   alarmNbr=7105   alarmSeverity=Minor
    ...   tableName=${ALARM_LIST_COMPONENT}   tableRow=${Minor_ROW}
    Run Keyword If   ${CLOUDCU}
    ...   Check If Alarm Exist In NE Alarm History   alarmNbr=7106   alarmSeverity=Major
    ...   tableName=${ALARM_LIST_COMPONENT}   tableRow=${MAJOR_ROW}
    Run Keyword If   ${CLOUDCU}
    ...   Check If Alarm Exist In NE Alarm History   alarmNbr=7108   alarmSeverity=Critical
    ...   tableName=${ALARM_LIST_COMPONENT}   tableRow=${CRITICAL_ROW}

Check If Alarm Exist In NE Alarm History
    [Arguments]  ${alarmNbr}   ${alarmSeverity}   ${tableName}   ${tableRow}
    ${alarm_number}   wait until keyword succeeds  3 times   5s
    ...   swing.Get Table Cell Value   identifier=${tableName}   row=${tableRow}   columnIdentifier=3
    Run Keyword If  '${alarm_number}'!='${alarmNbr}'   Fail
    ${alarm_severtiy}   wait until keyword succeeds  3 times   5s
    ...   swing.Get Table Cell Value   identifier=${tableName}   row=${tableRow}   columnIdentifier=0
    Run Keyword If  '${alarm_severtiy}'!='${alarmSeverity}'   Fail

Create View Folder
    [Arguments]    ${folder_name}
    swing.Select From Main Menu And Wait    menuPath=Tools|Managed Objects|View Explorer
    Wait Until Keyword Succeeds   15s   2s   swing.Select From Main Menu   menuPath=File|New|View Folder...
    run keyword and ignore error  Wait Until Keyword Succeeds   15s   2s   swing.Dialog Should Be Open   identifier=New View Folder
    Wait Until Keyword Succeeds   15s   2s   swing.Select Dialog   identifier=New View Folder
    Wait Until Keyword Succeeds  5s   1s   swing.Click On Component   identifier=CreationWizardPanel.myName
    Wait Until Keyword Succeeds   5s   1s   swing.Insert Into Text Field   identifier=CreationWizardPanel.myName   text=${folder_name}
    Wait Until Keyword Succeeds   15s    2s   swing.Push Button   identifier=Finish

Create View
    [Arguments]  ${view_folder_name}   ${view_name}
    Wait Until Keyword Succeeds   31s   10s   swing.Select From Main Menu And Wait   menuPath=Tools|Managed Objects|View Explorer
    Wait Until Keyword Succeeds   31s   10s   swing.Select Tree Node   identifier=Views   nodeIdentifier=${view_folder_name}
    sleep   2s
    Wait Until Keyword Succeeds   31s   10s   swing.Select From Main Menu And Wait   menuPath=File|New|View...
    sleep  2s
    swing.Select Dialog   identifier=New View
    sleep  2s
    List Components In Context
    Wait Until Keyword Succeeds  5s   1s   swing.Click On Component   identifier=CreationWizardPanel.myName
    Wait Until Keyword Succeeds   5s   1s   swing.Insert Into Text Field   identifier=CreationWizardPanel.myName   text=${view_name}
    Wait Until Keyword Succeeds   15s    2s   swing.Push Button   identifier=Finish

Copy NE to View
    [Arguments]  ${view_folder_name}   ${view_name}   ${DN}
    Select Main Window
    swing.Select From Menu And Wait   menuPath=Tools|Managed Objects|Object Explorer
    Sleep    5s
    swing.Select Tree Node   identifier=Objects   nodeIdentifier=${DN}
    Wait Until Keyword Succeeds   30s   2s   swing.Select From Menu And Wait   menuPath=Edit|Copy
    Select Main Window
    swing.Select From Menu And Wait   menuPath=Tools|Managed Objects|View Explorer
    swing.Select Tree Node   identifier=Views   nodeIdentifier=${view_folder_name}|${view_name}
    List Components In Context
    swing.Select From Tree Node Popup Menu   identifier=Views   nodeIdentifier=${view_folder_name}|${view_name}   menuPath=Edit
    List Components In Context
    Sleep   3s
    Wait Until Keyword Succeeds   30s   2s   swing.Select From Menu And Wait   menuPath=Edit|Paste
    sleep   5s
    Wait Until Keyword Succeeds   30s   2s   swing.Select From Menu And Wait   menuPath=File|Save
    sleep   10s
    Wait Until Keyword Succeeds   30s   10s
    ...   swing.Click On Tree Node   Views   ${view_folder_name}|${view_name}   \#0   2
    List Components In Context

Delete View Folder
    [Arguments]  ${view_folder_name}
    Wait Until Keyword Succeeds   30s   10s   swing.Select From Main Menu And Wait   menuPath=Window|Reset Workspace
    sleep   5s
    Wait Until Keyword Succeeds   10s   5s   swing.Select From Menu And Wait   menuPath=Tools|Managed Objects|View Explorer
    Sleep   5s
    Wait Until Keyword Succeeds   10s   2s   swing.Select Tree Node   identifier=Views   nodeIdentifier=${view_folder_name}
    Sleep   5s
    List Components In Context
    Wait Until Keyword Succeeds   10s   5s   swing.Select From Menu And Wait   menuPath=Edit|Delete
    Sleep   5s
    swing.List Windows
    Sleep   5s
    Wait Until Keyword Succeeds   15s   5s   swing.Select Dialog   identifier=Confirm Deletion
    Sleep   5s
    Wait Until Keyword Succeeds   10s   2s   swing.Push Button   identifier=Yes
    Sleep   5s

Acknowledge Alarm From Alarm List
    [Arguments]    ${table_name}   ${search_key_dict}
#    ${alarm_row}   Alarm Should Exist In NE Specific AlarmList   ${table_name}   ${alarm_number}    ${alarm_severity}
    ${alarm_row}   wait until keyword succeeds  1min   10s   Find Alarm for MO in FM Monitor
    ...   table_name=${table_name}   search_key_dict=${search_key_dict}   alarm_status=${true}
    wait until keyword succeeds  3 times   3s   swing.Select Main Window
    swing.Component Should Exist    ${table_name}
    FOR    ${i}    IN RANGE    1    3
        ${op_status}=    Run Keyword And Return Status    Wait Until Keyword Succeeds    20s    2s    swing.Select From Table Cell Popup Menu
        ...    identifier=${table_name}   row=${alarm_row}   columnIdentifier=0   menuPath=Acknowledge
        Exit For Loop If    '${op_status}'=='True'
    END
    Run Keyword If    '${op_status}'=='False'    FAIL
    Sleep    2
    swing.Select Main Window

Trigger All Alarms
    Run Keyword If   ${CLASSICAL} or ${CLOUDDU}
    ...   COAM Update Parameter ON COAM ADMIN
    ...   dist_name=${MO_NAME}/MNL-1/MNLENT-1/SECADM-1
    ...   parameter=actServiceAccountSsh
    ...   value=true

    Run Keyword If   ${CLOUDCU}   Trigger fake alarm for BTS
    ...   NE_class=cloud   severity=Minor   status=raise   alarm_nbr=7105
    Run Keyword If   ${CLOUDCU}   Trigger fake alarm for BTS
    ...   NE_class=cloud   severity=Major   status=raise   alarm_nbr=7106
    Run Keyword If   ${CLOUDCU}   Trigger fake alarm for BTS
    ...   NE_class=cloud   severity=Critical   status=raise   alarm_nbr=7108

Cancel All Alarms
    Run Keyword If   ${CLASSICAL} or ${CLOUDDU}
    ...   COAM Update Parameter ON COAM ADMIN
    ...   dist_name=${MO_NAME}/MNL-1/MNLENT-1/SECADM-1
    ...   parameter=actServiceAccountSsh
    ...   value=false

    Run Keyword If   ${CLOUDCU}   Trigger fake alarm for BTS
    ...   NE_class=cloud   severity=Minor   status=clear   alarm_nbr=7105
    Sleep   2s
    Run Keyword If   ${CLOUDCU}   Trigger fake alarm for BTS
    ...   NE_class=cloud   severity=Major   status=clear   alarm_nbr=7106
    Sleep   2s
    Run Keyword If   ${CLOUDCU}   Trigger fake alarm for BTS
    ...   NE_class=cloud   severity=Critical   status=clear   alarm_nbr=7108
    Sleep   2s
