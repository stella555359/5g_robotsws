*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   ../Resource/NetAct_Fast_Pass_common.robot

*** Variables ***
&{NetAct_Error_LOGS}    FM=@{FM_Error_LOGS}
@{FM_Error_LOGS}   /var/opt/oss/log/fm/fmservices/oss_error_FMCluster_*_*.log

*** Keywords ***
FM Monitor alarm upload
    [Arguments]   ${DN}=PLMN-PLMN|${MO_NAME}   ${Tab_path}=Alarm Upload
    ${remote_port}   Open Monitor
    set test variable   ${remote_port}
    Select MO and Open Popup Menu in FM Monitor   mo_name=${DN}   popup_menu=${Tab_path}
    Check If 9228 Exist On Alarm History
    Check FM Error Log

Check If 9228 Exist On Alarm History
    Select MO and Open Popup Menu in FM Monitor   mo_name=PLMN-PLMN|${MO_NAME}   popup_menu=Find In|Alarm History
    sleep    15s
    ${alarm_number}   wait until keyword succeeds  10 times   2s
    ...   swing.Get Table Cell Value   identifier=${ALARM_LIST_COMPONENT}   row=0   columnIdentifier=3
    ${alarm_number_status}    run keyword if  '${alarm_number}'=='9228'   set variable  ${True}
    ...   ELSE   set variable  ${False}
    ${alarm_text}   run keyword if  '${alarm_number}'=='9228'
    ...   swing.Get Table Cell Value   identifier=${ALARM_LIST_COMPONENT}   row=0   columnIdentifier=4
    ${alarm_text_status}      run keyword if   '${alarm_text}'=='ALARM DATABASE UPLOAD IN PROGRESS'   set variable   ${True}
      ...   ELSE   set variable   ${False}
    run keyword if  not ${alarm_number_status} or ${alarm_text_status}   Fail

Check FM Error Log
    ${current_time}   Get Current Date   result_format=epoch
    ${yesterday_time}   Subtract Time From Date   ${current_time}   8 hours      result_format=epoch
    run keyword   Check FM Error Logs from NetAct   node_ip=${HOST_IP['${WAS_DMGR_HOSTS[0]}']}
    ...   username=${SERVICE_USER}    password=${SERVICE_PASSWORD}   Log_Area=FM   yesterday_time=${yesterday_time}

Check FM Error Logs from NetAct
    [Documentation]   Check FM Error Logs from NetAct
    ...    Author: shengyuan.jiang@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | Log_Area | yes | Area of log |
    ...   | download_path | no | path to save log |
    ...   | yesterday_time | no | formate time of yesterday |
    ...    *RETURN VALUE*
    ...    no
    ...    Example
    ...    |  Catch Logs from NetAct | FM |
    [Arguments]    ${node_ip}   ${username}   ${password}   ${Log_Area}   ${yesterday_time}
    ...    ${download_path}=${OUTPUTDIR}/
    ${connection_NetAct}    csn.connect_to   hostname=${node_ip}   username=${username}   password=${password}   alias=NetAct_WASnode
    ${NetAct_logs}    set variable    ${NetAct_Error_LOGS['${Log_Area}']}
    FOR    ${item}    IN    @{NetAct_logs}
      ${output}  Download And Show FM Error Log from NetAct    log=${item}    alias=${connection_NetAct}
      Check FM Output Detail     output=${output}   yesterday_time=${yesterday_time}
    END
    [Teardown]    csn.disconnect    connection=${connection_NetAct}

Download And Show FM Error Log from NetAct
    [Documentation]   Download And Show FM Error Log from NetAct
    ...    Author: shengyuan.jiang@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | log | yes | log name which contain log path |
    ...   | alias | yes | connetion between taf and NetAct |
    ...   | download_path | no | path to save log |
    ...    *RETURN VALUE*
    ...    FM_log_output
    ...    Example
    ...    |  Catch Logs from NetAct | /var/opt/oss/log/audit/oss_error_FMCluster_*_*.log | ${connection_NetAct} |
    [Arguments]    ${log}    ${alias}    ${download_path}=${OUTPUTDIR}/
    ${all_log}    csn.Execute    command=ls -lt ${log}    connection=${alias}
    ${status}    run keyword and return status    should contain    ${log}    *
    ${log_reg}    run keyword if    ${status}    set variable    ${log.split('/')[-1].split('*')[0]}
    ...    ELSE    set variable    ${log.split('/')[-1].split('.')[0]}
    ${log_path}    Remove String Using Regexp    ${log}    ${log_reg}.*.log
    ${log_name}    should match regexp    ${all_log}    ${log_reg}.*.log
    ${current_date}    Get Current Date
    ${DATE_STR}    Convert Date    ${current_date}    %Y%m%d%H%M
    csn.download_file    remote_path=${log_path}${log_name}    local_path=${download_path}${DATE_STR}_${log_name}    connection=${alias}
    ${FM_log_output}   csn.Execute   command=cat ${log_path}${log_name}  connection=${alias}   timeout=60
    [Return]  ${FM_log_output}

Check FM Output Detail
    [Arguments]   ${output}   ${yesterday_time}
    @{detail_list}   Split String   ${output}   \r\n
    FOR   ${detail}   IN   @{detail_list}
        ${detail_time}  Get Lines Containing String   ${detail}    | ERROR |
        ${detail_line_count}  Get Line Count   ${detail_time}
       Continue for loop if    ${detail_line_count}==0
       ${detail_time}   Fetch From Left   ${detail_time}     +
       ${detail_time}    Convert Date    ${detail_time}
       ${detail_time}    Convert Date    ${detail_time}    result_format=epoch
       Run Keyword If   ${detail_time} > ${yesterday_time}   Log To Console   ${detail}
       Run Keyword If   ${detail_time} > ${yesterday_time}   Should Not Contain   ${detail}   ${MO_NAME}
      Exit for loop if    ${detail_time} < ${yesterday_time}
    END

Case Setup: FM_Monitor_alarm_upload
    Login NetAct Start Page and Remove File

Case Teardown: FM_Monitor_alarm_upload
    Run Keyword And Ignore Error   Close Java Application by Remote Port   remote_port=${remote_port}
    Run Keyword And Ignore Error   Close All Java Application Forced
    Run Keyword And Ignore Error   selenium_netact.Logout
    Run Keyword And Ignore Error   selenium_coam.Logout
    Run Keyword And Ignore Error   Common Case Teardown
    run keyword if test failed  run keyword and ignore error   Catch Logs from NetAct   node_ip=${HOST_IP['${WAS_DMGR_HOSTS[0]}']}
    ...   username=${SERVICE_USER}   password=${SERVICE_PASSWORD}   Log_Area=FM
    run keyword if test failed  run keyword and ignore error   Catch Logs from NetAct   node_ip=${HOST_IP['${JBI_COMMONMEDIATION_HOSTS[0]}']}
    ...   username=${SERVICE_USER}    password=${SERVICE_PASSWORD}   Log_Area=COMMON_MEDIATION
