*** Settings ***
Documentation    author: Deng Xueqin
...              Group: RAN_PZ_HAZ3_SG02
...              contact: xueqin.deng@nokia-sbell.com


Library     taf.sw.dcap.rd		WITH NAME	DCAP


*** Variables ***
${cpc_host}    ${tl.ues[0].ssh_connection_details.addr}
${cpc_user}    ${tl.ues[0].ssh_connection_details.username}
${cpc_password}    ${tl.ues[0].ssh_connection_details.password}
${emil_win_dir}      C:\\\\Emil_Test\\\\
${EMIL_log_file_list}    Create List
${emil_log_dir}      /cygdrive/c/Emil_Test/
${emil_path}         /cygdrive/c/Program Files/Emil/
${emil_cmd_pre}      start /wait Emil.exe
${emil_win_path}     C:\\\\Program Files\\\\Emil
${local_dir}    ${OUTPUT_DIR}

*** Keywords ***       
Convert emil log at cpc
    [Arguments]    ${local_emil_log_path}    ${end_file}
    log to console     start checking emil logs
    wait until keyword succeeds  10min   20s    csn.Connect to   hostname=${cpc_host}
    ...   username=${cpc_user}    password=${cpc_password}    alias=cpc
    csn.execute    command=rm -rf ${emil_log_dir}/*    connection=cpc
    ${local_emil_log_dir}   ${file_name}   Split Path    ${local_emil_log_path}
    log to console     ${file_name}
    csn.Upload File   local_path=${local_emil_log_path}   remote_path=${emil_log_dir}/${file_name}   connection=cpc
    csn.execute    command=unzip -j ${emil_log_dir}/*.zip "*/*.5gm" -d ${emil_log_dir}/     connection=cpc
    log to console     unzip finish
    ${EMIL_log_file}    csn.execute    command= find ${emil_log_dir}/ -name "*.5gm"    connection=cpc
    ${EMIL_log_file}    strip string   ${EMIL_log_file}
    ${EMIL_log_file_list}    split string   ${EMIL_log_file} 
    log to console    begin convert emil
    ${output_txt_path}    Covert Emil Logs to TXT    file_list=${EMIL_log_file_list}   local_dir=${emil_log_dir}
    ...   emil_host=${cpc_host}   emil_user=${cpc_user}   emil_password=${cpc_password}
    ...   emil_protocol=5G    connection=cpc
    set suite variable    ${output_txt_path}
    log to console    convert emil done
    [Teardown]  run keyword and ignore error   csn.Disconnect    connection=cpc
    
Covert Emil Logs to TXT
    [Arguments]   ${file_list}   ${local_dir}   ${emil_host}    ${emil_user}    ${emil_password}
    ...    ${emil_protocol}    ${connection}=emil
    [Documentation]    Convert Emil log to txt format, and download to UTE VM
    ...    ${emil_host} should be one UE CTRL PC which install emil software
    ...    ${emil_protocol}    can be "5G" or "5G Cell Trace", one of folder name in C:\Program Files\Emil\profiles
    ${emil_param}    Catenate    -AutoClose -Profile SourceProfileUser.ini
    ...                          -ProfilePath "${emil_win_path}\\profiles\\${emil_protocol}" -Variable OutPath
    ${curr_date}   DateTime.Get Current Date   result_format=%Y%m%d_%H%M   exclude_millis=True
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
    ...   local_path=${OUTPUT_DIR}/Emil_${curr_date}.txt   connection=${connection}
    [Return]   ${OUTPUT_DIR}/Emil_${curr_date}.txt
    [Teardown]   csn.Disconnect   connection=${connection}

Convert Emil Log
    [Arguments]   ${emil_file}   ${emil_param}    ${connection}=emil
    ${curr_date}   DateTime.Get Current Date   result_format=%Y%m%d_%H%M%S   exclude_millis=True
    ${log_dir}   ${file_name}   Split Path   ${emil_file}
    ${cmd}   Set Variable
    ...   ${emil_cmd_pre} \"${emil_win_dir}${file_name}\" ${emil_param} \"${emil_win_dir}Emil_${curr_date}.txt\"
    OperatingSystem.Create File   path=${OUTPUT_DIR}/get_emil.bat   content=${cmd}
    csn.Execute   command=cd \"${emil_log_dir}\";rm -f Emil_${curr_date}.txt   connection=${connection}
    csn.Upload File   local_path=${OUTPUT_DIR}/get_emil.bat
    ...   remote_path=${emil_log_dir}/get_emil.bat   connection=${connection}
    csn.Execute   command=mv \"${emil_log_dir}/get_emil.bat\" \"${emil_path}\"   connection=${connection}
    csn.Execute   command=cd \"${emil_path}\";cmd.exe /c get_emil.bat   connection=${connection}
    Wait Until Keyword Succeeds   3x   15s   Emil TXT convert done
    ...   file_path=${emil_log_dir}/Emil_${curr_date}.txt   connection=${connection}
    [Return]   ${emil_log_dir}/Emil_${curr_date}.txt

Emil TXT convert done
    [Arguments]   ${file_path}   ${connection}
    ${file_exist}   csn.File Exists   remote_path=${file_path}   connection=${connection}
    Should Be True   ${file_exist}
