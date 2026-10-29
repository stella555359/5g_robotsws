*** Settings ***
Resource   Common.robot

*** Variables ***
# ${emil_path}         /cygdrive/c/Program Files/Emil
# ${emil_win_path}     C:\\\\Program Files\\\\Emil
# ${emil_log_dir}      /cygdrive/c/temp/emil_logs
# ${emil_win_dir}      C:\\\\temp\\\\emil_logs\\\\
# ${emil_cmd_pre}      start /wait Emil.exe


*** Keywords ***
Upload IDA File To EMIL Server
    [Arguments]   ${sack_file_list}   ${emil_host}    ${emil_user}    ${emil_password}   ${connection}=emil
    csn.Connect to   hostname=${emil_host}   username=${emil_user}   password=${emil_password}   alias=${connection}
    ${remote_sack_dir}   csn.Execute   command=find /cygdrive/c/Users/ -name "EmilSacks"   connection=${connection}
    ${remote_sack_dir}   Strip String   ${remote_sack_dir}
    FOR   ${sack_file}   IN   @{sack_file_list}
        ${local_sack_dir}   ${sack_file_name}   Split Path   ${sack_file}
        csn.Upload File   local_path=${sack_file}   remote_path=${remote_sack_dir}/${sack_file_name}   connection=${connection}
        csn.Execute   command=cd ${remote_sack_dir}; tar -xvf ${sack_file_name}   connection=${connection}
    END
    [Teardown]   csn.Disconnect   connection=${connection}


Covert Emil Logs to TXT
    [Arguments]   ${file_list}   ${emil_host}    ${emil_user}    ${emil_password}
    ...    ${emil_protocol}=5G   ${local_dir}=${OUTPUT_DIR}   ${connection}=emil
    csn.Connect to   hostname=${emil_host}   username=${emil_user}   password=${emil_password}   alias=${connection}
    @{emil_txt_list}   Create List
    FOR   ${emil_file}   IN   @{file_list}
        ${file_dir}   ${file_name}   Split Path   ${emil_file}

        csn.Execute   command=mkdir -p /cygdrive/c/temp/emil_logs/   connection=${connection}
        csn.Upload File   local_path=${emil_file}   remote_path=/cygdrive/c/temp/emil_logs/${file_name}   connection=${connection}

        ${curr_date}   DateTime.Get Current Date   result_format=%Y%m%d_%H%M%S   exclude_millis=True
        ${cmd}   Catenate   SEPARATOR=
        ...   "/cygdrive/c/Program Files/Emil/Emil.exe"
        ...   ${SPACE}"C:\\\\\\\\temp\\\\\\\\emil_logs\\\\\\\\${file_name}"
        ...   ${SPACE}-AutoClose -Profile SourceProfileUser.ini
        ...   ${SPACE}-ProfilePath "C:\\\\\\\\Program Files\\\\\\\\Emil\\\\\\\\profiles\\\\\\\\${emil_protocol}"
        ...   ${SPACE}-Variable OutPath "C:\\\\\\\\temp\\\\\\\\emil_logs\\\\\\\\Emil_${curr_date}.txt"

        csn.Execute   command=${cmd}   connection=${connection}
        Sleep   3s
        ${emil_txt_path}   Set Variable   /cygdrive/c/temp/emil_logs/Emil_${curr_date}.txt
        Append To List   ${emil_txt_list}   ${emil_txt_path}
    END
    Should Not Be Empty   ${emil_txt_list}

    ${emil_list_str}   Evaluate   ' '.join(${emil_txt_list})
    ${curr_date}   DateTime.Get Current Date   result_format=%Y%m%d_%H%M   exclude_millis=True
    csn.Execute   cat ${emil_list_str} > /cygdrive/c/temp/emil_logs/Emil_${curr_date}.txt   connection=${connection}
    csn.Download File   remote_path=/cygdrive/c/temp/emil_logs/Emil_${curr_date}.txt
    ...   local_path=${local_dir}/Emil_${curr_date}.txt   connection=${connection}
    [Return]   ${local_dir}/Emil_${curr_date}.txt
    [Teardown]   csn.Disconnect   connection=${connection}


# Covert Emil Logs to TXT
#     [Arguments]   ${file_list}   ${emil_host}    ${emil_user}    ${emil_password}
#     ...    ${emil_protocol}=5G   ${local_dir}=${OUTPUT_DIR}   ${connection}=emil
#     [Documentation]    Convert Emil log to txt format, and download to UTE VM
#     ...    ${emil_host} should be one UE CTRL PC which install emil software
#     ...    ${emil_protocol}    can be "5G" or "5G Cell Trace", one of folder name in C:\Program Files\Emil\profiles
#     ${emil_param}    Catenate    -AutoClose -Profile SourceProfileUser.ini
#     ...                          -ProfilePath "${emil_win_path}\\profiles\\${emil_protocol}" -Variable OutPath
#     ${curr_date}   Get Current Date   result_format=%Y%m%d_%H%M   exclude_millis=True
#     ${emil_list}   Create List
#     csn.Connect to   hostname=${emil_host}   username=${emil_user}   password=${emil_password}   alias=${connection}
#     csn.Execute   command=rm -rf \"${emil_path}/get_emil.bat\"   connection=${connection}
#     ${emil_files}   Create List
#     FOR   ${emil_file}   IN   @{file_list}
#        ${file_name}   Convert Emil Log   emil_file=${emil_file}    emil_param=${emil_param}    connection=${connection}
#        Append To List   ${emil_list}   ${file_name}
#     END
#     ${emil_list_str}   Evaluate   ' '.join(${emil_list})
#     csn.Execute   cat ${emil_list_str} > ${emil_log_dir}/Emil_${curr_date}.txt   connection=${connection}
#     csn.Download File   remote_path=${emil_log_dir}/Emil_${curr_date}.txt
#     ...   local_path=${local_dir}/Emil_${curr_date}.txt   connection=${connection}
#     [Return]   ${local_dir}/Emil_${curr_date}.txt
#     [Teardown]   csn.Disconnect   connection=${connection}


# Convert Emil Log
#     [Arguments]   ${emil_file}   ${emil_param}    ${connection}=emil
#     ${curr_date}   Get Current Date   result_format=%Y%m%d_%H%M%S   exclude_millis=True
#     ${local_dir}   ${file_name}   Split Path   ${emil_file}
#     ${cmd}   Set Variable   ${emil_cmd_pre} \"${emil_win_dir}${file_name}\" ${emil_param} \"${emil_win_dir}Emil_${curr_date}.txt\"
#     OperatingSystem.Create File   path=${OUTPUT_DIR}/get_emil.bat   content=${cmd}
#     csn.Execute   command=mkdir -p \"${emil_log_dir}\"   connection=${connection}
#     csn.Execute   command=cd \"${emil_log_dir}\";rm -f Emil_${curr_date}.txt   connection=${connection}
#     csn.Upload File   local_path=${emil_file}   remote_path=${emil_log_dir}/${file_name}   connection=${connection}
#     csn.Upload File   local_path=${OUTPUT_DIR}/get_emil.bat   remote_path=${emil_log_dir}/get_emil.bat   connection=${connection}
#     csn.Execute   command=mv \"${emil_log_dir}/get_emil.bat\" \"${emil_path}\"   connection=${connection}
#     csn.Execute   command=cd \"${emil_path}\";cmd /c get_emil.bat   connection=${connection}
#     Wait Until Keyword Succeeds   3x   15s   Emil TXT convert done
#     ...   file_path=${emil_log_dir}/Emil_${curr_date}.txt   connection=${connection}
#     [Return]   ${emil_log_dir}/Emil_${curr_date}.txt


# Emil TXT convert done
#     [Arguments]   ${file_path}   ${connection}
#     ${file_exist}   csn.File Exists   remote_path=${file_path}   connection=${connection}
#     Should Be True   ${file_exist}

