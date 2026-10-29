*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   ./NetAct_Fast_Pass_common.robot


*** Variables ***
${ALARM_LIST_COMPONENT}    DesktopViewTable
${SEARCH_BOX}   Search
@{alarm_list}   0
@{alarm_severity}   0
&{SEVERITY_NBR_ON_BTS}   Critical=2   Major=3   Minor=4
&{SEVERITY_NBR_ON_NetAct}   Critical=1   Major=2   Minor=3
*** Keyword ***
My Swing Table Row Count Should Be Stable
    [Documentation]   Check if Swing Table Row Count is Stable
    ...    Author: shengyuan.jiang@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | tableId | yes | table name |
    ...   | sleepTimeSeconds | no | sleep time before get new table |
    ...    *RETURN VALUE*
    ...    no
    ...    Example
    ...    |  My Swing Table Row Count Should Be Stable |DesktopViewTable | 1 |
    [Arguments]    ${tableId}    ${sleepTimeSeconds}=5
    ${rowCount}=    swing.Get Table Row Count    ${tableId}
    Sleep    ${sleepTimeSeconds}s
    ${newRowCount}=    swing.Get Table Row Count    ${tableId}
    Should Be Equal As Integers    ${rowCount}    ${newRowCount}

Select MO and Open Popup Menu in FM Monitor
    [Documentation]   Open Tab on Monitor for Specified NE
    ...    Author: shengyuan.jiang@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | DN | yes | MO |
    ...   | Tab_path | yes | the function path |
    ...    *RETURN VALUE*
    ...    no
    ...    Example
    ...    |  Select MO and Open Popup Menu in FM Monitor |PLMN-PLMN|MRBTS-3000 | Find In|Alarm List |
    [Arguments]  ${mo_name}   ${popup_menu}
    wait until keyword succeeds  20s   5s   swing.Switch to Application    Monitor
    wait until keyword succeeds  20s   2s   swing.Select Main Window
    swing.Select From Main Menu And Wait    Tools|Managed Objects|Object Explorer
    sleep   5s
    wait until keyword succeeds  20s   5s   swing.Select Tree Node   Objects   ${mo_name}
    sleep   5s
    Wait Until Keyword Succeeds    16s    5s   swing.Select From Tree Node Popup Menu   Objects   ${mo_name}  ${popup_menu}


Open Monitor
    [Documentation]   Open Monitor and reset workspace
    ...    Author: shengyuan.jiang@nokia-sbell.com
    ...    *RETURN VALUE*
    ...    remote port of Monitor
    ...    Example
    ...    |  Open Monitor |
    ${remote_port}   Open Application   Monitor
    swing.Select From Main Menu And Wait    Window|Reset Workspace
    sleep   5s
    [Return]   ${remote_port}

Trigger fake alarm for BTS
    [Documentation]   Trigger fake alarm for BTS
    ...    Author: shengyuan.jiang@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | NE_class | yes | class of NE(classical or cloud) |
    ...   | severity | yes | alarm severity(Critical or Major or Minor) |
    ...   | status | yes | alarm status(raise or clear) |
    ...   | alarm_nbr | yes | alarm number |
    ...    *RETURN VALUE*
    ...    no
    ...    Example
    ...    |  Trigger fake alarm for BTS | classical | Critical | raise | 7100 |
    [Arguments]   ${NE_class}   ${severity}   ${status}   ${alarm_nbr}
    ${severity_nbr}=   set variable  ${SEVERITY_NBR_ON_BTS['${severity}']}
    ${command}   set variable  flexalarm --${status} -ap=cluster -sp=${alarm_nbr} -mo=moid7100 -iinfo=testevents10 -se=${severity_nbr}
    ${NE_con}   csn.connect_to   ${oam_addr}   ${oam_username}   ${oam_password}   alias=NE_connection
    run keyword if  '${NE_class}'=='classical'   csn.execute
    ...   command=lxc-attach -n 0xe001 -- /opt/nokia/bin/${command}   connection=${NE_con}   timeout=10s
    ...   ELSE   csn.execute   command=${command}   connection=${NE_con}   timeout=10s

#Check no Alarm on Monitor
#    [Arguments]  ${alarm_list}=0   ${alarm_severity}=0
#    ${alarm_quantity}   set variable  0
#    ${alarm_quantity}   BuiltIn.Convert To Integer   ${alarm_quantity}
#    ${length}   Get Length   @{alarm_list}
#    swing.Select From Main Menu And Wait    Window|Reset Workspace
#    sleep   5s
#    Select MO and Open Popup Menu in FM Monitor   PLMN-PLMN|${MO_NAME}   Find In|Alarm List
#    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    30s    2s    swing.Component Should Exist    ${ALARM_LIST_COMPONENT}
#    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    1 min    5 sec
#    ...   My Swing Table Row Count Should Be Stable    ${ALARM_LIST_COMPONENT}    8 sec
#    ${total_alarm}   swing.Get Table Row Count   ${ALARM_LIST_COMPONENT}
#    run keyword if  ${total_alarm}>${length}   fail  Unexpected alarms are on Moitor
#    : FOR    ${index}    IN RANGE    ${length}
#    \   run keyword if  '${alarm_list[0]}'=='0'   should be equal   ${total_alarm}    0
#    \   exit for loop if  '${alarm_list[0]}'=='0'
#    \   ${status}   run keyword if  '${total_alarm}'> ${length}   set variable  ${false}
#    \   exit for loop if  '${status}'=='false'
#    \   ${alarm_status}   ${alarmRow}   Wait Until Keyword Succeeds    40s    20s
#        ...   Check If Alarm Exist On Alarm List   ${ALARM_LIST_COMPONENT}   ${alarm_list[${index}]}  ${alarm_severity[${index}]}
#    \   ${alarm_quantity}   run keyword if  ${alarm_status}  evaluate  ${alarm_quantity}+1
#    run keyword if  ${alarm_quantity}!= ${total_alarm}   fail  Unexpected alarms are on Moitor

Check no Alarm on NetAct Backend
    [Documentation]   Check no Alarm on NetAct Backend
    ...    Author: shengyuan.jiang@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | alarm_list | no | alarm number |
    ...   | alarm_severity | no | alarm severity |
    ...    *RETURN VALUE*
    ...    return No Alarm on NetAct if there is no alarm, else no return
    ...    Example
    ...    |  Check no Alarm on NetAct Backend |
    [Arguments]  ${alarm_list}=@{alarm_list}   ${alarm_severity}=@{alarm_severity}
    ${length}   Get Length   ${alarm_list}
    ${alias}=  csn.Connect To    ${HOST_IP['${WAS_DMGR_HOSTS[0]}']}
    ...   ${SERVICE_USER}   ${SERVICE_PASSWORD}    alias=NetActNode
    ${output}   csn.Send Command   command=sqlplus omc   connection=${alias}
    ${readout}   csn.Read Output Until  match=assword:   timeout=5s   connection=${alias}
    csn.Write Input  data=omc\n  connection=${alias}
    ${readout}   csn.Read Output Until  match=SQL>   timeout=5s   connection=${alias}
    csn.Write Input   data=SELECT count(*) FROM FX_ALARM WHERE DN='PLMN-PLMN/${MO_NAME}' AND ALARM_STATUS='1';\n   connection=${alias}
    ${readout}   csn.Read Output Until   match=SQL>   timeout=5s   connection=${alias}
    ${total_alarm}   Should Match Regexp   ${readout}   \\d+
    return from keyword if   ${total_alarm}==0   No Alarm on NetAct
    Run Keyword If   ${total_alarm}>${length}   fail   Unexpected alarms are on NetAct
    ${command_part1}   set variable  SELECT count(*) FROM FX_ALARM WHERE DN='PLMN-PLMN/${MO_NAME}' AND ALARM_STATUS='1' AND ALARM_NUMBER=
    FOR    ${index}    IN RANGE    ${length}
       Run Keyword If   '${alarm_list[0]}'=='0'   should be equal   ${total_alarm}   0
       exit for loop if  '${alarm_list[0]}'=='0'
       ${SeverityNbr}   set variable  ${SEVERITY_NBR_ON_NetAct['${alarm_severity[${index}]}']}
       ${command}   set variable   ${command_part1}'${alarm_list[${index}]}' AND SEVERITY='${SeverityNbr}';\n
       csn.Write Input   data=${command}   connection=${alias}
       ${readout}   csn.Read Output Until   match=SQL>   timeout=5s   connection=${alias}
       ${alarm_quantity_in_NetAct}   Should Match Regexp   ${readout}   \\d+
       run keyword if  ${alarm_quantity_in_NetAct}>1   fail
    END
    [Teardown]  csn.disconnect   connection=${alias}

Open Alarm Details Window and Check
    [Documentation]   Open Alarm Details Window and Check text can be wrote in search box
    ...    Author: shengyuan.jiang@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | table_name | yes | table name |
    ...   | search_key_dict | yes | the text that will be wrote in search box  |
    ...    *RETURN VALUE*
    ...    no
    ...    Example
    ...    |  Open Alarm Details Window and Check | ${ALARM_LIST_COMPONENT} | fault |
    [Arguments]    ${table_name}   ${search_key_dict}
#    ${alarmRow}   Wait For Incoming Alarm Into NE Specific AlarmList   ${ALARM_LIST_COMPONENT}   ${alarm_number}   ${alarm_severity}
    ${alarmRow}   Wait Until Keyword Succeeds   2min   10s   Find Alarm for MO in FM Monitor   ${table_name}   ${search_key_dict}   ${true}
    Wait Until Keyword Succeeds    30s    5s    swing.Click On Table Cell    ${table_name}    ${alarm_row}    1
    ...    2
    Wait Until Keyword Succeeds    30s    5s    swing.Select Window    Alarm Details
    List Components In Context
    Run Keyword And Ignore Error	Wait Until Keyword Succeeds   5s   1s   swing.Text Field Should Be Enabled   ${SEARCH_BOX}
    Wait Until Keyword Succeeds   5s   1s   swing.Insert Into Text Field   ${SEARCH_BOX}     ${search_key_dict['alarmName']}
    sleep   10s
    ${alarm_numer_from_MP}    Get Label Content    AlarmTitle
    Should Be Equal  ${alarm_numer_from_MP}    ${search_key_dict['alarmName']}
    ${window_regexp}    Set Variable    regexp=.*.*- Alarm Details$
    Wait Until Keyword Succeeds    1 min    5 sec    swing.Select Window    ${window_regexp}
    run keyword and ignore error  Wait Until Keyword Succeeds    10s    2s    swing.Button Should Be Enabled    Close
    Push Button    Close
    Sleep    1
    Select Main window

Find Alarm for MO in FM Monitor
    [Documentation]   Find if Expected Alarm exited or not for MO in FM Monitor
    ...    Author: shengyuan.jiang@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | table_name | yes | table name |
    ...   | search_key_dict | yes | search criteria  |
    ...   | alarm_status | yes | alarm status(true or false)  |
    ...    *RETURN VALUE*
    ...    alarm row if alarm exited
    ...    Example
    ...    |  Find Alarm for MO in FM Monitor | ${ALARM_LIST_COMPONENT} | severity=Critical   alarmName=7108 | ${true} |
    [Arguments]  ${table_name}   ${search_key_dict}   ${alarm_status}
    ${table_rows}   ${table_headers}   ${status}   Find Items In Table Content   ${table_name}   ${search_key_dict}
    run keyword if  ${alarm_status}!=${status}   Fail   Alarm status is wrong
    Return From Keyword If  ${status}    ${table_rows[0]['row']}
#    [Return]  ${table_rows[0]['row']}
