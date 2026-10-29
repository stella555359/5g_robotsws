*** Settings ***
Documentation    Author: sheng.1.ye@nokia-sbell.com

Library    taf.transport.ssh           WITH NAME    ssh
Library    glob

Library   OperatingSystem
Library   DateTime
Library   Collections


*** Variables ***
${default_emil_protocol}   5G
${emil_host}     10.68.251.15
${emil_user}     ute
${emil_password}     ute

${emil_path}         /cygdrive/c/Program Files/Emil
${emil_win_path}     C:\\Program Files\\Emil
${emil_log_dir}      /cygdrive/c/temp/emil_logs
${emil_win_dir}      C:\\\\temp\\\\emil_logs\\\\
${emil_cmd_pre}      start /wait Emil.exe

*** Keywords ***
Connect To Emil
    SSH.Connect to   hostname=${emil_host}   username=${emil_user}   password=${emil_password}   alias=emil


Convert Emil To Text 
    [Arguments]   ${source}   ${emil_protocol}=${default_emil_protocol}   ${target}=${None}   ${connection}=emil

    ${new_target}         Set Variable         ${source}.txt
    ${target}             Set Variable If    ${target}==${None}     ${new_target}        ${target}
    
    Return From Keyword If     str.endswith("${source}", ".txt")
    Run Keyword If        not os.path.exists("${source}")      Log To Console        File ${source} does not exist!
    Return From Keyword If     not os.path.exists("${source}")

    ${emil_param}    Catenate    -AutoClose -Profile SourceProfileUser.ini
    ...                          -ProfilePath "${emil_win_path}\\profiles\\${emil_protocol}" -Variable OutPath

    ${local_dir}   ${file_name}   Split Path   ${source}
    ${out_local_dir}   ${out_file_name}   Split Path   ${target}
    ${cmd}   Set Variable   ${emil_cmd_pre} \"${emil_win_dir}${file_name}\" ${emil_param} \"${emil_win_dir}${out_file_name}\"

    OperatingSystem.Create File   path=${out_local_dir}/get_emil.bat   content=${cmd}
    SSH.Execute   command=cd \"${emil_log_dir}\";rm -f ${out_file_name}   connection=${connection}
    SSH.Upload File   local_path=${source}   remote_path=${emil_log_dir}/${file_name}   connection=${connection}
    SSH.Upload File   local_path=${out_local_dir}/get_emil.bat   remote_path=${emil_log_dir}/get_emil.bat   connection=${connection}
    SSH.Execute   command=mv \"${emil_log_dir}/get_emil.bat\" \"${emil_path}\"   connection=${connection}
    SSH.Execute   command=cd \"${emil_path}\";cmd.exe /c get_emil.bat   connection=${connection}
    Log To Console            Wait for Emil txt ${out_file_name} generation ...
    Wait Until Keyword Succeeds   3x   15s   Emil TXT convert done
    ...   file_path=${emil_log_dir}/${out_file_name}   connection=${connection}

    SSH.Download File   remote_path=${emil_log_dir}/${out_file_name}
    ...   local_path=${target}   connection=${connection}

    Run Keyword If     os.path.exists("${target}")
    ...    Log To Console    Converting emil file: ${source} to text: ${target} Done
    ...    ELSE   Log To Console    Converting pcap file: ${source} to text: ${target} Fail
    [Return]   ${target}


Emil TXT convert done
    [Arguments]   ${file_path}   ${connection}
    ${file_exist}   SSH.File Exists   remote_path=${file_path}   connection=${connection}
    Should Be True   ${file_exist}


Batch Convert Emil To Text
    [Arguments]  ${source}   ${emil_protocol}=${default_emil_protorol}    ${connection}=emil
    @{source_list}      glob.glob         ${source}
    :FOR     ${source_file}   IN     @{source_list} 
    \        Convert Emil To Text    source=${source_file}   emil_protocol=${emil_protocol}   connection=${connection}
