*** Settings ***
Documentation    Author: jingmin.he@nokia-sbell.com

Library   taf.transport.ssh   WITH NAME   csn
Library   OperatingSystem
Library   DateTime
Library   Collections
Variables   ../libraries/emil_vars.py
Variables   ../../libraries/global_vars.py

*** Variables ***
&{trace_folder_list}
#...   10.57.167.129=/sharedvolume/ltetracer/traces/CellTrace/
#...   10.57.157.163=/data/ntracer_10/
#...   10.101.60.41=/sharedvolume/ntracer5g/_data/celltrace/
...   10.57.195.82=/sharedvolume/ntracer5g/_data/celltrace/
...   10.57.195.83=/sharedvolume/ntracer5g/_data/celltrace/

&{trace_name_list}
#...   10.57.167.129=ltetracer
#...   10.57.157.163=ltetracer
#...   10.101.60.41=nTracer
...   10.57.195.82=nTracer
...   10.57.195.83=nTracer

# ${trace_host}   ${tl.test_pcs[0].default_ssh_connection_details.addr}
# ${trace_user}   ${tl.test_pcs[0].default_ssh_connection_details.username}
# ${trace_password}   ${tl.test_pcs[0].default_ssh_connection_details.password}
${dcap_private_key_path}   ${CURDIR}/../libraries/utfuser.private.key

*** Keywords ***
Check Session Setup
    [Arguments]   ${setup}=${true}   ${connection}=ltetracer
    Wait Until Keyword Succeeds   5m   20s   csn.Connect to
    ...   hostname=${trace_host}   username=${trace_user}    key_path=${dcap_private_key_path}   alias=${connection}
    ${sessions}   csn.Execute   command=netstat -tan | grep 49148   connection=${connection}
    ${exists}   Run Keyword and Return Status   Should Contain   ${sessions}   ${asik_addr}
    Should Be Equal   ${exists}   ${setup}
    [Teardown]   csn.Disconnect   connection=${connection}

Get Latest Trace File Name
    [Arguments]   ${bts_id}=${tl.gnbs[0].global_bts_id}   ${connection}=ltetracer
    [Timeout]   5m
    Set Suite Variable   ${trace_folder}   ${trace_folder_list}[${trace_host}]
    Set Suite Variable   ${trace_name}   ${trace_name_list}[${trace_host}]
#    Wait Until Keyword Succeeds   5m   20s   csn.Connect to
#    ...   hostname=${trace_host}   username=${trace_user}   password=${trace_password}   alias=${connection}
    Wait Until Keyword Succeeds   5m   20s   csn.Connect to
    ...   hostname=${trace_host}   username=${trace_user}    key_path=${dcap_private_key_path}   alias=${connection}
    Run Keyword and Ignore Error   csn.Execute
    ...   command=find ${trace_folder} -mtime +2 -name \"\*\.\*\" -exec rm -rf \{\} \\;   connection=${connection}
    ${trace_files}   csn.Execute   command=find ${trace_folder} -name \"ne${bts_id}\*\" | xargs ls --sort=time -r   connection=${connection}
    ${trace_files}   Set Variable   ${trace_files.splitlines()}
    Return From Keyword If   len(${trace_files})==0 or (len(${trace_files})==1 and '${trace_files[0]}'=='')    ${EMPTY}
    [Return]   ${trace_files[-1]}
    [Teardown]   csn.Disconnect   connection=${connection}

Get Newest Trace Files
    [Arguments]  ${latest_skip_file}  ${local_dir}=${OUTPUT_DIR}   ${bts_id}=${tl.gnbs[0].global_bts_id}   ${connection}=ltetracer
    ...   ${latest_file_skipped}=${true}
    ${file_list}   Create List
#    Wait Until Keyword Succeeds   5m   20s   csn.Connect to
#    ...   hostname=${trace_host}   username=${trace_user}   password=${trace_password}   alias=${connection}
    Wait Until Keyword Succeeds   5m   20s   csn.Connect to
    ...   hostname=${trace_host}   username=${trace_user}    key_path=${dcap_private_key_path}   alias=${connection}
    ${trace_files}   csn.Execute   command=find ${trace_folder} -name \"ne${bts_id}\*\" | xargs ls --sort=time -r   connection=${connection}
    ${trace_files}   Set Variable   ${trace_files.splitlines()}
    Return From Keyword If   len(${trace_files})==0 or (len(${trace_files})==1 and '${trace_files[0]}'=='')    ${EMPTY}
    ${last_index}   Run Keyword If   $latest_skip_file==''   Set Variable   ${-1}
    ...   ELSE   Get Index From List   ${trace_files}   ${latest_skip_file}
    ${total_files}   Get Length   ${trace_files}
    ${latest_file_skipped}   Set Variable If  '${total_files}'=='${last_index+1}'   ${false}   ${true}
    ${start_index}   Set Variable If   ${latest_file_skipped}   ${last_index+1}   ${last_index}
    FOR   ${index}    IN RANGE    ${start_index}   ${total_files}
       ${trace_dir}   ${trace_file_name}   Split Path   ${trace_files[${index}]}
       ${trace_file_name}   Set Variable   ${trace_file_name.replace(":", "")}
       csn.Download File   remote_path=${trace_files[${index}]}   local_path=${local_dir}/${trace_file_name}   connection=${connection}
       Append To List   ${file_list}   ${local_dir}/${trace_file_name}
    END
    [Return]   ${file_list}
    [Teardown]   csn.Disconnect   connection=${connection}

Covert Emil Logs to TXT
    [Arguments]   ${file_list}   ${local_dir}=${OUTPUT_DIR}   ${connection}=emil
    ${curr_date_no_sec}   Get Current Date   result_format=%Y%m%d_%H%M   exclude_millis=True
    ${emil_list}   Create List
    Wait Until Keyword Succeeds   5m   20s   csn.Connect to
    ...   hostname=${emil_host}   username=${emil_user}   password=${emil_password}   alias=${connection}
    csn.Execute   command=rm -rf \"${emil_path}/get_emil.bat\"   connection=${connection}
    ${emil_files}   Create List
    FOR   ${emil_file}   IN   @{file_list}
       ${file_not_empty}   ${curr_date}   Emil Empty or Not   emil_file=${emil_file}   connection=${connection}
       Run Keyword If   '${file_not_empty}'=='${False}'   Continue For Loop
       ${txt_file}   Wait Until Keyword Succeeds   3x   10s   Convert Emil Log    curr_date=${curr_date}
       ...  connection=${connection}
       Append To List   ${emil_list}   ${txt_file}
    END
    ${emil_list_str}   Evaluate   ' '.join(${emil_list})
    Run Keyword If   ${emil_list}   csn.Execute   cat ${emil_list_str} > ${emil_log_dir}/Emil_${curr_date_no_sec}.txt
    ...   connection=${connection}
    ...   ELSE   Create File   ${local_dir}/Emil_${curr_date}.txt
    Run Keyword If   ${emil_list}   csn.Download File   remote_path=${emil_log_dir}/Emil_${curr_date_no_sec}.txt
    ...   local_path=${local_dir}/Emil_${curr_date_no_sec}.txt   connection=${connection}
    [Return]   ${local_dir}/Emil_${curr_date_no_sec}.txt
    [Teardown]   csn.Disconnect   connection=${connection}

Convert Emil Log
    [Arguments]   ${curr_date}  ${connection}=emil
    csn.Execute   command=taskkill /im emil.exe /f   connection=${connection}   timeout=30
    csn.Execute   command=mv \"${emil_log_dir}/get_emil.bat\" \"${emil_path}\"   connection=${connection}
    csn.Execute   command=cd \"${emil_path}\";cmd.exe /c get_emil.bat   connection=${connection}
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

Emil Empty or Not
    [Arguments]   ${emil_file}    ${connection}=emil
    ${local_dir}   ${file_name}   Split Path   ${emil_file}
    ${curr_date}   Get Current Date   result_format=%Y%m%d_%H%M%S   exclude_millis=True
    ${cmd}   Set Variable   ${emil_cmd_pre} \"${emil_win_dir}${file_name}\" ${emil_param} \"${emil_win_dir}Emil_${curr_date}.txt\"
    OperatingSystem.Create File   path=${OUTPUT_DIR}/get_emil.bat   content=${cmd}
    csn.Execute   command=cd \"${emil_log_dir}\";rm -f Emil_${curr_date}.txt   connection=${connection}   timeout=30
    Wait Until Keyword Succeeds   3x   10s   Emil Upload File Successful
    ...   local_path=${emil_file}   remote_path=${emil_log_dir}/${file_name}   connection=${connection}
    Wait Until Keyword Succeeds   3x   10s   Emil Upload File Successful
    ...   local_path=${OUTPUT_DIR}/get_emil.bat   remote_path=${emil_log_dir}/get_emil.bat   connection=${connection}
    ${file_size}   csn.Execute   command=du ${emil_log_dir}/${file_name}| grep 1 | head -c 1   connection=${connection}
    ${file_not_empty}   Set Variable If   '${file_size}'=='0'   ${False}   ${True}
    [Return]   ${file_not_empty}   ${curr_date}
