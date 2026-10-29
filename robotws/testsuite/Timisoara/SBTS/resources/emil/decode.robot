*** Settings ***
Documentation   This is common keyword for 5GC001681 cases coam parts.
...              Author: Han Ruiyu
...              Contact: ruiyu.han@nokia-sbell.com
...              Squard: HZ SG7
Library    OperatingSystem
Library   Collections
Library    taf.transport.ssh   WITH NAME   csn
Variables   ../libraries/sherpa_server_1.py
Library     ../libraries/snapshot_files.py

*** Variables ***
${Sherpa_decode}    "C:/Program Files/Nokia/Sherpa_5G18/Sherpa.exe" -o c:/sherpa_log -d 2000 -p Sherpa C:/sherpa_log/

*** Keywords ***
Get and Upload Files Needs Decode
    [Arguments]   ${sherpa_log_list}   ${sherpa_server}=${sherpa_server_ip}     #${ip}=${asik_addr}   ${src}=${OUTPUT_DIR}
    ...   ${sherpa_username}=${sherpa_server_username}   ${sherpa_password}=${sherpa_server_password}
    ...   ${sherpa_log_folder}=${sherpa_server_local}
#    ${file_list}   OperatingSystem.List Files In Directory   ${src}   *.pcap
   wait until keyword succeeds  5min   20s  csn.Connect to   hostname=${sherpa_server}
   ...   username=${sherpa_username}   password=${sherpa_password}   alias=sherpa_decode
    ${output_state}    csn.Execute   command=cd ${sherpa_server_local}   connection=sherpa_decode
    run keyword if  ${output_state.count('No such file or directory')} > 0
    ...   csn.Execute   command=mkdir ${sherpa_server_local}   connection=sherpa_decode
    csn.Execute   command=cd ${sherpa_server_local};rm -f *   connection=sherpa_decode
    FOR   ${file}   IN   @{sherpa_log_list}
       ${sherpa_log_path_name_tmp}    fetch from right    ${file}    /
       ${sherpa_log_path_name}    Remove String    ${sherpa_log_path_name_tmp}    :
       csn.Upload File   local_path=${file}   remote_path=${sherpa_log_folder}${/}${sherpa_log_path_name}   connection=sherpa_decode
    END
#    [Return]   ${file_list}
    [Teardown]   csn.Disconnect   connection=sherpa_decode

Get Biggest CSV File
    [Arguments]   ${alias}   ${sherpa_log_folder}=${sherpa_server_local}
    ${csv_files}   Create Dictionary
    ${csv_list}   csn.Execute   command=cd ${sherpa_log_folder};ls -la *.csv   connection=${alias}
    ${biggest_size}   Set Variable   0
    FOR   ${csv_info}   IN   @{csv_list.splitlines()}
       ${csv_items}   Set Variable   ${csv_info.split()}
       ${csv_size}   Set Variable   ${csv_items[5]}
       ${file_name}   Set Variable   ${csv_items[9]}
       Set to Dictionary   ${csv_files}   ${csv_size}=${file_name}
    END
    FOR   ${csv_size}   IN   @{csv_files.keys()}
       ${biggest_size}   Run Keyword If  ${${csv_size}}>${${biggest_size}}   Set Variable   ${csv_size}
       ...   ELSE   Set Variable   ${biggest_size}
    END
    [Return]   ${csv_files['${biggest_size}']}

Decode_Sherpa_log
    [Arguments]
    ${file_list}    Get and Upload Files Needs Decode
    should not be empty  ${file_list}
    Log to console   Start decode files
    Csn.Connect to   hostname=${sherpa_server_ip}    username=${sherpa_server_username}    password=${sherpa_server_password}
    ...    alias=sherpa_decode
    FOR   ${file}   IN   @{file_list}
       csn.Execute   command=ps -ef | grep csv | awk '{print $2}' | xargs kill -9   connection=sherpa_decode
#       csn.Execute   command=cd ${sherpa_server_local};rm -f *   connection=sherpa_decode
       csn.Execute    command=${Sherpa_decode}${file}   connection=sherpa_decode
       Sleep   10s
       ${file_csv}    Get Biggest CSV File   alias=sherpa_decode
       csn.Download File   remote_path=${sherpa_server_local}${/}${file_csv}   local_path=${OUTPUT_LOG_PATH}${/}${file_csv}
       ...   connection=sherpa_decode
       Log to console   ${file_csv} donwloaded for ${file}
       decode_csv    csv_filename=${OUTPUT_LOG_PATH}/${file_csv}
    END
    [Teardown]   csn.Disconnect   connection=sherpa_decode

Convert Pcaps to CSV
    [Arguments]    ${local_sherpa_list}
    Get and Upload Files Needs Decode    sherpa_log_list=${local_sherpa_list}
#    should not be empty  ${file_list}
    Log to console   Start Convert sherpa files......
    Wait Until Keyword Succeeds    5min    20s
    ...    Csn.Connect to   hostname=${sherpa_server_ip}    username=${sherpa_server_username}    password=${sherpa_server_password}
    ...    alias=sherpa_decode
    csn.Execute   command=ps -ef | grep csv | awk '{print $2}' | xargs kill -9   connection=sherpa_decode
    csn.Execute    command=${Sherpa_decode}   connection=sherpa_decode
#    Sleep   5min
    ${csv_file_list}   csn.Execute    command=cd ${sherpa_server_local};ls -l *csv  connection=sherpa_decode
    FOR   ${file_csv_info}   IN   @{csv_file_list.splitlines()}
       log to console     in loop ${file_csv_info}
       ${file_csv}    strip string    ${file_csv_info}
       ${file_csv}    fetch from right   ${file_csv}    ${SPACE}
       csn.Download File   remote_path=${sherpa_server_local}${/}${file_csv}   local_path=${OUTPUT_LOG_PATH}${/}${file_csv}
        ...   connection=sherpa_decode   timeout=120s
    END
#    sleep   5min
#    Log to console   ${file_csv} donwloaded for ${file}
    [Teardown]   csn.Disconnect   connection=sherpa_decode
