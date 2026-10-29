*** Settings ***
Documentation    Author: jingmin.he@nokia-sbell.com
...    Please rewrite your variable in the testcase if not the same with default values
Library   taf.transport.ssh   WITH NAME   csn
Library   OperatingSystem
Library   DateTime
Library   Collections


*** Variables ***
${emil_path}         /cygdrive/c/Program Files/Emil
${emil_win_path}     C:\\Program Files\\Emil
${emil_log_dir}      /cygdrive/c/temp/emil_logs
${emil_win_dir}      C:\\\\temp\\\\emil_logs\\\\
${emil_cmd_pre}      start /wait Emil.exe
${docker_cmd}        docker exec -it FlowTracer /bin/bash -c \'./fcmd ${trace_host}:50001
${session_param2}    pl=\[n:flowdiskwriter\]\[c:@ext/config/_diskwriter_TA.conf\]\[s:1\]
${provider_create}   ${docker_cmd} cp provider ${asik_addr}:20401\'
${asik_addr}         ${tl.gnbs[0].dus[0].f1_m_ip_addr}


*** Keywords ***
Check Session Setup
    [Arguments]   ${trace_host}   ${trace_user}   ${trace_password}    ${setup}=${true}   ${connection}=ltetracer
    csn.Connect to   hostname=${trace_host}   username=${trace_user}   password=${trace_password}   alias=${connection}
    ${sessions}   csn.Execute   command=netstat -tan | grep 49151   connection=${connection}
    ${exists}   Run Keyword and Return Status   Should Contain   ${sessions}   ${asik_addr}
    Should Be Equal   ${exists}   ${setup}
    [Teardown]   csn.Disconnect   connection=${connection}

Get Latest Trace File Name By BTSID
    [Arguments]   ${trace_host}   ${trace_user}   ${trace_password}    ${bts_id}    ${trace_folder}   ${connection}=ltetracer
    [Documentation]    ${trace_folder}   can be  /sharedvolume/ntracer/_data/  or  /sharedvolume/ltetracer/traces/CellTrace/
    csn.Connect to   hostname=${trace_host}   username=${trace_user}   password=${trace_password}   alias=${connection}
    ${trace_files}   csn.Execute   command=find ${trace_folder} -name \"ne${bts_id}\*\"   connection=${connection}
    ${trace_files}   Set Variable   ${trace_files.splitlines()}
    Return From Keyword If   len(${trace_files})==1 and '${trace_files[0]}'==''    ${EMPTY}
    [Return]   ${trace_files[-1]}
    [Teardown]   csn.Disconnect   connection=${connection}

Get Newest Trace Files By BTSID
    [Arguments]   ${trace_host}   ${trace_user}   ${trace_password}    ${bts_id}  ${latest_skip_file}  ${local_dir}   ${trace_folder}
    ...    ${connection}=ltetracer
    [Documentation]    ${trace_folder}   can be  /sharedvolume/ntracer/_data/  or  /sharedvolume/ltetracer/traces/CellTrace/
    ${file_list}   Create List
    csn.Connect to   hostname=${trace_host}   username=${trace_user}   password=${trace_password}   alias=${connection}
    ${trace_files}   csn.Execute   command=find ${trace_folder} -name \"ne${bts_id}\*\"   connection=${connection}
    ${trace_files}   Set Variable   ${trace_files.splitlines()}
    Return From Keyword If   len(${trace_files})==1 and '${trace_files[0]}'==''    ${EMPTY}
    ${last_index}   Get Index From List   ${trace_files}   ${latest_skip_file}
    ${total_files}   Get Length   ${trace_files}
    FOR   ${index}    IN RANGE    ${last_index}   ${total_files}
          ${trace_dir}   ${trace_file_name}   Split Path   ${trace_files[${index}]}
          ${trace_file_name}   Set Variable   ${trace_file_name.replace(":", "")}
          csn.Download File   remote_path=${trace_files[${index}]}   local_path=${local_dir}/${trace_file_name}   connection=${connection}
          Append To List   ${file_list}   ${local_dir}/${trace_file_name}
    END
    [Return]   ${file_list}
    [Teardown]   csn.Disconnect   connection=${connection}

Covert Emil Logs to TXT
    [Arguments]   ${file_list}   ${local_dir}   ${emil_host}    ${emil_user}    ${emil_password}
    ...    ${emil_protocol}    ${connection}=emil
    [Documentation]    Convert Emil log to txt format, and download to UTE VM
    ...    ${emil_host} should be one UE CTRL PC which install emil software
    ...    ${emil_protocol}    can be "5G" or "5G Cell Trace", one of folder name in C:\Program Files\Emil\profiles
    ${emil_param}    Catenate    -AutoClose -Profile SourceProfileUser.ini
    ...                          -ProfilePath "${emil_win_path}\\profiles\\${emil_protocol}" -Variable OutPath
    ${curr_date}   Get Current Date   result_format=%Y%m%d_%H%M   exclude_millis=True
    ${emil_list}   Create List
    csn.Connect to   hostname=${emil_host}   username=${emil_user}   password=${emil_password}   alias=${connection}
    csn.Execute   command=rm -rf \"${emil_path}/get_emil.bat\"   connection=${connection}
    ${emil_files}   Create List
    FOR   ${emil_file}   IN   @{file_list}
       ${file_name}   Convert Emil Log   emil_file=${emil_file}    emil_param=${emil_param}    connection=${connection}
       Append To List   ${emil_list}   ${file_name}
    END
    ${emil_list_str}   Evaluate   ' '.join(${emil_list})
    csn.Execute   cat ${emil_list_str} > ${emil_log_dir}/Emil_${curr_date}.txt   connection=${connection}
    csn.Download File   remote_path=${emil_log_dir}/Emil_${curr_date}.txt
    ...   local_path=${local_dir}/Emil_${curr_date}.txt   connection=${connection}
    [Return]   ${local_dir}/Emil_${curr_date}.txt
    [Teardown]   csn.Disconnect   connection=${connection}

Convert Emil Log
    [Arguments]   ${emil_file}   ${emil_param}    ${connection}=emil
    ${curr_date}   Get Current Date   result_format=%Y%m%d_%H%M%S   exclude_millis=True
    ${local_dir}   ${file_name}   Split Path   ${emil_file}
    ${cmd}   Set Variable   ${emil_cmd_pre} \"${emil_win_dir}${file_name}\" ${emil_param} \"${emil_win_dir}Emil_${curr_date}.txt\"
    OperatingSystem.Create File   path=${OUTPUT_DIR}/get_emil.bat   content=${cmd}
    csn.Execute   command=cd \"${emil_log_dir}\";rm -f Emil_${curr_date}.txt   connection=${connection}
    csn.Upload File   local_path=${emil_file}   remote_path=${emil_log_dir}/${file_name}   connection=${connection}
    csn.Upload File   local_path=${OUTPUT_DIR}/get_emil.bat   remote_path=${emil_log_dir}/get_emil.bat   connection=${connection}
    csn.Execute   command=mv \"${emil_log_dir}/get_emil.bat\" \"${emil_path}\"   connection=${connection}
    csn.Execute   command=cd \"${emil_path}\";cmd /c get_emil.bat   connection=${connection}
    Wait Until Keyword Succeeds   3x   15s   Emil TXT convert done
    ...   file_path=${emil_log_dir}/Emil_${curr_date}.txt   connection=${connection}
    [Return]   ${emil_log_dir}/Emil_${curr_date}.txt

Emil TXT convert done
    [Arguments]   ${file_path}   ${connection}
    ${file_exist}   csn.File Exists   remote_path=${file_path}   connection=${connection}
    Should Be True   ${file_exist}

Start Flowtracer
    [Arguments]   ${trace_host}   ${trace_user}   ${trace_password}    ${session_param1}
    [Documentation]    author: Wang Yixiang
    ${session_create}   set variable
    ...      ${docker_cmd} cm n=session p=provider ${session_param1} ${session_param2}'
    wait until keyword succeeds    3x    5s    csn.Connect to   hostname=${trace_host}    username=${trace_user}    password=${trace_password}
    ...    alias=DCAP
    csn.Execute    command=docker start FlowTracer   connection=DCAP
    sleep   2s
    ${res}=   csn.Execute    command=${provider_create}    connection=DCAP
    should contain    ${res}       success
    ${res}=   csn.Execute   command=${session_create}    connection=DCAP
    should contain    ${res}       success
    [Teardown]   csn.Disconnect     connection=DCAP

Stop Flowtracer
    [Arguments]    ${trace_host}   ${trace_user}   ${trace_password}
    [Documentation]    author: Wang Yixiang
    ${provider_list}    _Query Existing Flowtracer Provider
    ...    trace_host=${trace_host}   trace_user=${trace_user}   trace_password=${trace_password}
    ${session_list}     _Query Existing Flowtracer Session
    ...    trace_host=${trace_host}   trace_user=${trace_user}   trace_password=${trace_password}
    _Delete Flowtracer Resource    provider_list=${provider_list}    session_list=${session_list}
    ...    trace_host=${trace_host}   trace_user=${trace_user}   trace_password=${trace_password}

_Delete Flowtracer Resource
    [Arguments]   ${trace_host}   ${trace_user}   ${trace_password}    ${provider_list}    ${session_list}
    ...   ${trace_host}=${trace_host}    ${trace_user}=${trace_user}    ${trace_password}=${trace_password}
    [Documentation]    author: Wang Yixiang
    csn.Connect to   hostname=${trace_host}    username=${trace_user}    password=${trace_password}
    ...    alias=DCAP
    csn.Execute    command=ls   connection=DCAP
    run keyword if   ${session_list}   _Remove_Resource      ${session_list}    dm
    run keyword if   ${provider_list}   _Remove_Resource      ${provider_list}    dp
    [Teardown]   csn.Disconnect     connection=DCAP

_Remove_Resource
    [Arguments]    ${resource_list}    ${cmd}
    [Documentation]    author: Wang Yixiang
    FOR    ${resource}   IN  @{resource_list}
        ${output}    csn.Execute   command=${docker_cmd} ${cmd} ${resource}\'    connection=DCAP
        Sleep   2s
        should not contain    ${output}   failed
        should not contain    ${output}   command not found
    END

_Query Existing Flowtracer Provider
    [Arguments]   ${trace_host}=${trace_host}    ${trace_user}=${trace_user}    ${trace_password}=${trace_password}
    [Documentation]    author: Wang Yixiang
    wait until keyword succeeds    3x    5s    csn.Connect to   hostname=${trace_host}    username=${trace_user}    password=${trace_password}
    ...    alias=DCAP
    ${provider_list}    csn.Execute   command=${docker_cmd} gp\'    connection=DCAP
    ${provider_list}    Fetch from right    ${provider_list}    Provider controllers:
    ${provider_list}    strip string    ${provider_list}
    ${provider_list}    Split string    ${provider_list}    \r\n
    ${provider_new_list}    create list
    FOR  ${provider}  IN   @{provider_list}
         ${provider}    strip string    ${provider}
         run keyword if  not "${provider}"== "${EMPTY}"    append to list    ${provider_new_list}    ${provider}
    END
    [Return]     ${provider_new_list}
    [Teardown]   csn.Disconnect     connection=DCAP

_Query Existing Flowtracer Session
    [Arguments]   ${trace_host}=${trace_host}    ${trace_user}=${trace_user}    ${trace_password}=${trace_password}
    [Documentation]    author: Wang Yixiang
    wait until keyword succeeds    3x    5s    csn.Connect to   hostname=${trace_host}    username=${trace_user}    password=${trace_password}
    ...    alias=DCAP
    ${session_list}    csn.Execute   command=${docker_cmd} gm\'    connection=DCAP
    ${session_list}    Fetch from right    ${session_list}    Monitoring sessions:
    ${session_list}    strip string    ${session_list}
    ${session_list}    Split string    ${session_list}    \r\n
    ${session_new_list}    create list
    FOR  ${session}  IN   @{session_list}
         ${session}    strip string    ${session}
         run keyword if  not "${session}"== "${EMPTY}"   append to list    ${session_new_list}    ${session}
    END
    [Return]     ${session_new_list}
    [Teardown]   csn.Disconnect     connection=DCAP

Remove Emil logs on DCAP
    [Arguments]   ${trace_host}   ${trace_user}   ${trace_password}    ${log_path_DCAP}=/sharedvolume/flowtracer/tmp/5G
    [Documentation]    author: Wang Yixiang
    csn.Connect to   hostname=${trace_host}    username=${trace_user}    password=${trace_password}
    ...    alias=DCAP
    csn.execute  command=echo ${trace_password} | sudo -S rm -rf ${log_path_DCAP}/*  connection=DCAP   timeout=1s
    [Teardown]  csn.Disconnect     connection=DCAP

Download FlowTracer logs to local
    [Arguments]    ${trace_host}   ${trace_user}   ${trace_password}    ${local_dir}
    ...    ${log_path_DCAP}=/sharedvolume/flowtracer/tmp/5G    ${connection}=ltetracer
    [Documentation]    author: Wang Yixiang
    log to console     Download FlowTracer logs to local
    ${file_list}   Create List
    ${current_date}     Get Current Date    result_format=%Y%m%d
    ${current_time}     Get Current Date        result_format=%Y%m%d_%H%M%S
    csn.Connect to   hostname=${trace_host}    username=${trace_user}    password=${trace_password}
    ...    alias=DCAP
    ${dir_name}    csn.Execute   command=ls ${log_path_DCAP}    connection=DCAP
    ${dir_name}    strip string    ${dir_name}
    ${length_dir}    get length    ${dir_name}
    run keyword if  ${length_dir}< ${2}    FAIL    [ERROR]Dcap Flowtracer trace didn't caught!
    ${dir_date_name}     csn.Execute   command=ls ${log_path_DCAP}/${dir_name}    connection=DCAP
    ${dir_date_name}    replace string    ${dir_date_name}   \r    ${SPACE}
    ${dir_date_name}    replace string    ${dir_date_name}   \n    ${SPACE}
    ${dir_date_name}    replace string    ${dir_date_name}   \t    ${SPACE}
    ${dir_date_name}    Split string    ${dir_date_name}    ${SPACE}
    Sort List    ${dir_date_name}
    FOR    ${item}    IN    @{dir_date_name}
           continue for loop if    '${item}'=='${empty}'
           ${log_name}     csn.Execute   command=ls ${log_path_DCAP}/${dir_name}/${item}    connection=DCAP
           ${log_name}    strip string    ${log_name}
           ${log_name}    Fetch From Right    ${log_name}   \r\n
           set suite variable    ${log_name}
           csn.Download File   remote_path=${log_path_DCAP}/${dir_name}/${item}/${logname}   local_path=${local_dir}/${log_name}
           ...   connection=DCAP
           Append To List   ${file_list}   ${local_dir}/${log_name}
    END
    [Return]   ${file_list}
    [Teardown]   csn.Disconnect     connection=DCAP

Upload file to remote host
    [Arguments]    ${emil_host}    ${emil_user}    ${emil_password}
    ...    ${local_filepath}    ${remote_filepath}
    [Documentation]    author: Wang Yixiang
    log to console     \n Upload file to remote host
    ${remote_path}    ${remote_file}    Split path    ${remote_filepath}
    csn.Connect to   hostname=${emil_host}    username=${emil_user}    password=${emil_password}
    ...    alias=remote_vm
    csn.execute    command=mkdir -p ${remote_path}     connection=remote_vm
    csn.Upload File   local_path=${local_filepath}  remote_path=${remote_filepath}  connection=remote_vm
    sleep    2s
    [Teardown]    csn.Disconnect    connection=remote_vm

Download NRTracer logs to local
    [Documentation]    Author: Wang Yixiang
    ...    Download NRtracer log to UTE log path
    [Arguments]   ${trace_host}=${tl.test_pcs[0].default_ssh_connection_details.addr}
    ...   ${trace_user}=${tl.test_pcs[0].default_ssh_connection_details.username}
    ...   ${trace_password}=${tl.test_pcs[0].default_ssh_connection_details.password}
    log to console     Download NRTracer logs to local
    ${file_list}   Create List
    ${cu_ip}    set variable    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ${current_date}     Get Current Date    result_format=%Y%m%d
    ${current_time}     Get Current Date        result_format=%Y%m%d_%H%M%S
    run    command=mkdir ${TS_CASE_LOG_PATH}/emil_${current_time}
    set Suite variable    ${emil_log_path_local}    ${TS_CASE_LOG_PATH}/emil_${current_time}
    ${server_emil_log_path}    set variable    /sharedvolume/ntracer/_data/${current_date}
    csn.Connect to   hostname=${trace_host}    username=${trace_user}    password=${trace_password}
    ...    alias=DCAP
    ${dir_name}    csn.Execute   command=ls ${server_emil_log_path}    connection=DCAP

    ${dir_name}    replace string    ${dir_name}   \r    ${SPACE}
    ${dir_name}    replace string    ${dir_name}   \n    ${SPACE}
    ${dir_name}    replace string    ${dir_name}   \t    ${SPACE}
    ${dir_name}    Split string    ${dir_name}    ${SPACE}
    Sort List    ${dir_name}
    ${path_exist}    csn.file_exists    remote_path=${server_emil_log_path}/${dir_name}[-1]    connection=DCAP
    run keyword if    ${path_exist}==${False}    Fail    Emil log not generated in dcap server:/sharedvolume/ntracer/_data/
    ${log_name}     csn.Execute   command=ls ${server_emil_log_path}/${dir_name}[-1]    connection=DCAP
    ${log_name}    replace string    ${log_name}   \r    ${SPACE}
    ${log_name}    replace string    ${log_name}   \n    ${SPACE}
    ${log_name}    replace string    ${log_name}   \t    ${SPACE}
    ${log_name}    Split string    ${log_name}    ${SPACE}
    FOR    ${item}    IN    @{log_name}
           ${cu_ip_flag}    run keyword and return status    should contain    ${item}    ${cu_ip}
           continue for loop if    ${cu_ip_flag}==${False}
           csn.Download File   remote_path=${server_emil_log_path}/${dir_name}[-1]/${item}   local_path=${emil_log_path_local}/${item}
           ...   connection=DCAP
           Append To List   ${file_list}   ${emil_log_path_local}/${item}
    END
    [Return]   ${file_list}
    [Teardown]   csn.Disconnect     connection=DCAP
