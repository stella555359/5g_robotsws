*** Settings ***
Documentation    Author: jingmin.he@nokia-sbell.com
Resource   Common.robot
Library     taf.sw.dcap.rd		WITH NAME	DCAP
#Library    ../Library/emil_vars.py
Variables    ../Library/emil_vars.py

*** Variables ***
&{trace_folder_list}
#...   10.57.157.163=/data/ntracer_10/
#...   10.101.60.41=/sharedvolume/ntracer5g/_data/celltrace/
...   10.57.195.82=/sharedvolume/ntracer5g/_data/celltrace/
...   10.57.195.83=/sharedvolume/ntracer5g/_data/celltrace/

&{trace_name_list}
#...   10.57.157.163=nTracer
#...   10.101.60.41=nTracer
...   10.57.195.82=nTracer
...   10.57.195.83=nTracer

${dcap_private_key_path}   ${CURDIR}/../Library/utfuser.private.key
${trace_folder}    /sharedvolume/ntracer*/_data/celltrace/
${dcap_server_ip}    192.168.255.126
${emil_host}    10.5.60.45
${emil_user}    wcdmata
${emil_password}    Aikon_123456*8
#${txt_file}     unknown
#${emil_cmd_pre}    start /wait Emil.exe
#${emil_param}  -AutoClose -Profile SourceProfileUser.ini -ProfilePath "C:\\Program Files\\Emil\\profiles\\%s\" -Variable OutPath" % emil_protocol
#${emil_protocol}    "5G Cell Trace"
#${emil_win_dir}    C:\\\\temp\\\\emil_logs\\\\


*** Keywords ***
Check Session Setup
    [Arguments]   ${setup}=${true}
    Wait Until Keyword Succeeds   5m   20s
    ...   csn.Connect To   hostname=${LOCAL_SSH_ADDR}   username=${LOCAL_SSH_USER}   password=${LOCAL_SSH_PWD}   alias=LOCAL
    ${sessions}   csn.Execute   command=netstat -tan | grep ${dcap_server_port}   connection=LOCAL
    ${exists}   Run Keyword and Return Status   Should Contain   ${sessions}   ${dcap_server_ip}
    Should Be Equal   ${exists}   ${setup}
    [Teardown]   csn.Disconnect   connection=LOCAL

Get Latest Trace File Name By BTSID
    [Arguments]   ${bts_id}=1
    [Timeout]   5m
#    Set Suite Variable   ${trace_folder}   ${trace_folder_list}[${dcap_server_ip}]
#    Set Suite Variable   ${trace_name}   ${trace_name_list}[${dcap_server_ip}]
#    Wait Until Keyword Succeeds   5m   20s   csn.Connect to
#    ...   hostname=${dcap_server_ip}   username=${dcap_server_username}    key_path=${dcap_private_key_path}   alias=${connection}
    Run    find ${trace_folder} -mtime +2 -name "*.*" -exec rm -rf {} \\\;
    ${trace_files}   Run    command=find ${trace_folder} -name \"ne${bts_id}\*\" | xargs ls --sort=time -r
#    Run Keyword and Ignore Error   csn.Execute
#    ...   command=find ${trace_folder} -mtime +2 -name \"\*\.\*\" -exec rm -rf \{\} \\;   #connection=${connection}
#    ${trace_files}   csn.Execute   command=find ${trace_folder} -name \"ne${bts_id}\*\" | xargs ls --sort=time -r   connection=${connection}
    ${trace_files}   Set Variable   ${trace_files.splitlines()}
    Return From Keyword If   len(${trace_files})==0 or (len(${trace_files})==1 and '${trace_files[0]}'=='')    ${EMPTY}
    [Return]   ${trace_files[-1]}
#    [Teardown]   csn.Disconnect   connection=${connection}

Get Newest Trace Files By BTSID
    [Arguments]  ${latest_skip_file}=${emil_last_file}  ${local_dir}=${OUTPUT_DIR}   ${latest_file_skipped}=${true}
    ${file_list}   Create List
#    Wait Until Keyword Succeeds   5m   20s   csn.Connect to
#    ...   hostname=${dcap_server_ip}   username=${dcap_server_username}   password=${dcap_server_password}   alias=${connection}
#    Wait Until Keyword Succeeds   5m   20s   csn.Connect to
#    ...   hostname=${dcap_server_ip}   username=${dcap_server_username}    key_path=${dcap_private_key_path}   alias=${connection}
   ${trace_files}   Run   find ${trace_folder} -name \"ne1\*\" | xargs ls --sort=time -r
    ${trace_files}   Set Variable   ${trace_files.splitlines()}
    Return From Keyword If   len(${trace_files})==0 or (len(${trace_files})==1 and '${trace_files[0]}'=='')    ${EMPTY}
    ${last_index}   Run Keyword If   $latest_skip_file==''   Set Variable   ${-1}
    ...   ELSE   Get Index From List   ${trace_files}   ${latest_skip_file}
    ${total_files}   Get Length   ${trace_files}
    ${latest_file_skipped}   Set Variable If  '${total_files}'=='${last_index+1}'   ${false}   ${true}
    ${start_index}   Set Variable If   ${latest_file_skipped}   ${last_index+1}   ${last_index}
    FOR   ${index}    IN RANGE    ${start_index}   ${total_files}
       ${trace_dir}   ${trace_file_name1}   Split Path   ${trace_files[${index}]}
       ${trace_file_name}   Set Variable   ${trace_file_name1.replace(":", "")}
       Run    cp ${trace_dir}/${trace_file_name1} ${local_dir}/${trace_file_name}
#       csn.Download File   remote_path=${trace_files[${index}]}   local_path=${local_dir}/${trace_file_name}   connection=${connection}
       Append To List   ${file_list}   ${local_dir}/${trace_file_name}
    END
    [Return]   ${file_list}
#    [Teardown]   csn.Disconnect   connection=${connection}

Covert Emil Logs to TXT
    [Arguments]   ${file_list}   ${local_dir}=${OUTPUT_DIR}   ${connection}=emil
    ${curr_date}   Get Current Date   result_format=%Y%m%d_%H%M   exclude_millis=True
    ${emil_list}   Create List
    Wait Until Keyword Succeeds   5m   20s   csn.Connect to
    ...   hostname=${emil_host}   username=${emil_user}   password=${emil_password}   alias=${connection}
    csn.Execute   command=rm -rf \"${emil_path}/get_emil.bat\"   connection=${connection}
    # csn.Execute   command=rm -rf ${emil_log_dir}   connection=${connection}
    csn.Execute   command=mkdir -p ${emil_log_dir}   connection=${connection}
    ${emil_files}   Create List
    FOR   ${emil_file}   IN   @{file_list}
       ${file_name}   Wait Until Keyword Succeeds   3x   10s   Convert Emil Log   emil_file=${emil_file}   connection=${connection}
       Append To List   ${emil_list}   ${file_name}
    END
    ${emil_list_str}   Evaluate   ' '.join(${emil_list})
    Run Keyword If   ${emil_list}   csn.Execute   cat ${emil_list_str} > ${emil_log_dir}/Emil_${curr_date}.txt
    ...   connection=${connection}
    ...   ELSE   Create File   ${local_dir}/Emil_${curr_date}.txt
    Run Keyword If   ${emil_list}   csn.Download File   remote_path=${emil_log_dir}/Emil_${curr_date}.txt
    ...   local_path=${local_dir}/Emil_${curr_date}.txt   connection=${connection}
    [Return]   ${local_dir}/Emil_${curr_date}.txt
    [Teardown]   csn.Disconnect   connection=${connection}

Convert Emil Log
    [Arguments]   ${emil_file}   ${connection}=emil
    ${curr_date}   Get Current Date   result_format=%Y%m%d_%H%M%S   exclude_millis=True
    ${local_dir}   ${file_name}   Split Path   ${emil_file}
#    ${cmd}   Set Variable   ${emil_cmd_pre} \"${emil_win_dir}${file_name}\" ${emil_param}${emil_protocol} \"${emil_win_dir}Emil_${curr_date}.txt\"
    ${cmd}   Set Variable   ${emil_cmd_pre} \"${emil_win_dir}${file_name}\" ${emil_param} \"${emil_win_dir}Emil_${curr_date}.txt\"
    OperatingSystem.Create File   path=${OUTPUT_DIR}/get_emil.bat   content=${cmd}
    csn.Execute   command=taskkill /im emil.exe /f   connection=${connection}   timeout=30
    csn.Execute   command=cd \"${emil_log_dir}\";rm -f Emil_${curr_date}.txt   connection=${connection}   timeout=30
    Wait Until Keyword Succeeds   3x   10s   Emil Upload File Successful
    ...   local_path=${emil_file}   remote_path=${emil_log_dir}/${file_name}   connection=${connection}
    Wait Until Keyword Succeeds   3x   10s   Emil Upload File Successful
    ...   local_path=${OUTPUT_DIR}/get_emil.bat   remote_path=${emil_log_dir}/get_emil.bat   connection=${connection}
    Wait Until Keyword Succeeds   3x   10s   Emil Upload File Successful
    ...   local_path=${CURDIR}/../Library/SourceProfileUser.ini   remote_path=${emil_log_dir}/SourceProfileUser.ini   connection=${connection}
    csn.Execute   command=mv \"${emil_log_dir}/get_emil.bat\" \"${emil_path}\"   connection=${connection}
    csn.Execute   command=mv \"${emil_log_dir}/SourceProfileUser.ini\" \"${emil_path}/profiles/${emil_protocol}\"   connection=${connection}
    csn.Execute   command=cd \"${emil_path}\";cmd /c get_emil.bat   connection=${connection}
    Wait Until Keyword Succeeds   3x   15s   Emil TXT convert done
    ...   file_path=${emil_log_dir}/Emil_${curr_date}.txt   connection=${connection}
    [Return]   ${emil_log_dir}/Emil_${curr_date}.txt

Emil Upload File Successful
    [Arguments]   ${local_path}   ${remote_path}   ${connection}
    csn.Upload File   local_path=${local_path}   remote_path=${remote_path}   connection=${connection}
    Wait Until Keyword Succeeds   3x   15s   csn.File Exists   remote_path=${remote_path}   connection=${connection}

Emil TXT convert done
    [Arguments]   ${file_path}   ${connection}
    ${file_exist}   csn.File Exists   remote_path=${file_path}   connection=${connection}
    Should Be True   ${file_exist}

Start DCAP log
    [Arguments]   ${bts_ip}
    log to console    \n Start DCAP log
    DCAP.connect_to     host=${dcapuser_addr}    port=443     username=${dcapuser_username}
    ...     password=${dcapuser_password}     rd_version=dcapv3    secure=True
    ${gnb_custom_profile}=     Create List     cp_5g
    ${output}    DCAP.start_trace     bts=${bts_ip}     gnb_custom_profile=${gnb_custom_profile}
    ...     wait_for_activation=${True}    control_plane_interface=${True}
    Log    ${output}[tracer_id]
    [Return]   ${output}

Stop DCAP log and convert to txt type
    [Arguments]   ${output}
    log to console    \n Stop DCAP log and convert to txt type
    ${profile_file}    set variable    SourceProfile_PMI_Ticket.ini
    ${stopstatus}    run keyword and return status    DCAP.stop_trace    trace_id=${output}[tracer_id]
    set suite variable    ${stopstatus}
    sleep    2m
    ${downloaded_emil_file_path}    DCAP.get_results    result_id=${output}[tracer_id]
    ...    target_dir=${TS_CASE_LOG_PATH}
    #Convert emil log at cpc    local_emil_log_path=${downloaded_emil_file_path}    end_file=5gm
    [Return]   ${downloaded_emil_file_path}
    #set suite variable     ${downloaded_emil_file_path}
