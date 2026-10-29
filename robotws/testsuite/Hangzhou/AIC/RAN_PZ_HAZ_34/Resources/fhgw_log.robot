*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   fhgw_log.robot



*** Variables ***



*** Keywords ***
_Get Wireshark From FHGW
    [Arguments]   ${initial_log_path}   ${log_stored_path}   ${alias}
    [Documentation]    _Get Wireshark From FHGW
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    |  initial_log_path  |  Yes |  Where is log stored on wireshark server |
    ...    |  log_stored_path | Yes | Where to save log on local PC  |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    |  _Get Wireshark From FHGW   |   /tmp/tmp_wireshark/ws_10.70.38.195_1514196349_69532.pcap   |  /home/ute/oam.pcap  |
    Send CTRL_C Interactively    alias=${alias}
    ${out}   issh.Execute  command=sync     alias=${alias}
    ${ip}   _Get FHGW Ip   alias=${alias}

    ${fhgw_account_info}  Get FHGW Account Info
    ${fhgw_root_username}   Set Variable    ${fhgw_account_info["root_username"]}
    ${fhgw_root_password}   Set Variable    ${fhgw_account_info["root_password_plain"]}

    ${tmp_alias}  Get Unique Id
    tafssh.Connect_To   hostname=${ip}   username=${fhgw_root_username}   password=${fhgw_root_password}   alias=${tmp_alias}
    tafssh.Download File   remote_path=${initial_log_path}    local_path=${log_stored_path}   connection=${tmp_alias}

    _Delete Old Wireshark File In FHGW   initial_log_path=${initial_log_path}    alias=${alias}


_Get Wireshark From RUPROXY
    [Arguments]   ${initial_log_path}   ${log_stored_path}   ${alias}
    [Documentation]   _Get Wireshark From RUPROXY
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    |  initial_log_path  |  Yes |  Where is log stored on wireshark server |
    ...    |  log_stored_path | Yes | Where to save log on local PC  |
    ...    ws_RUPROXY_1_z_9e3bf32d8fc3_edd182ca76574df59232717fad979dfe.pcap  format:
    ...    ws_RUPROXY_<vdu_index>_<pod_abbr>_<docker_id>_<uuid>.pcap
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | _Get Wireshark From RUPROXY | ws_RUPROXY_1_z_9e3bf32d8fc3_edd182ca76574df59232717fad979dfe.pcap | /home/ute/oam.pcap |
    Send CTRL_C Interactively    alias=${alias}

    #parse vdu_index, ru_index, docker_id
    #pod_abbr is ru_index for RUPROXY case
    ${path}  ${pcap_file}  OperatingSystem.Split Path   ${initial_log_path}
    ${tmp}   Split String  ${pcap_file}  _
    ${vdu_index}  Set Variable  ${tmp[2]}
    ${ru_index}  Set Variable  ${tmp[3]}
    ${container_id}   Set Variable  ${tmp[4]}

    ${fhgw_ip}   _Get FHGW Ip   alias=${alias}
    String Should Be An Ip Address  ${fhgw_ip}

    ${fhgw_account_info}  Get FHGW Account Info
    ${fhgw_root_username}   Set Variable    ${fhgw_account_info["root_username"]}
    ${fhgw_root_password}   Set Variable    ${fhgw_account_info["root_password_plain"]}

    Should Not Be Empty  ${fhgw_root_username}
    Should Not Be Empty  ${fhgw_root_password}

    Log To Console   ${container_id}
    ${out}    issh.Execute     command=docker exec -it ${container_id} sync    alias=${alias}
    ${out}    issh.Execute     command=docker exec -it ${container_id} chmod 777 ${initial_log_path}    alias=${alias}
    ${out}    issh.Execute     command=mkdir -p /tmp/tmp_wireshark    alias=${alias}
    ${out}    issh.Execute     command=ls -l /tmp/tmp_wireshark   alias=${alias}
    ${docker_cp}   Set Variable   sudo docker cp ${container_id}:${initial_log_path} /tmp/tmp_wireshark
    ${out}    issh.Execute     command=${docker_cp}    alias=${alias}
    ${out}    issh.Execute     command=sync    alias=${alias}

    ${tmp_alias}  Get Unique Id
    tafssh.Connect_To   hostname=${fhgw_ip}   username=${fhgw_root_username}    password=${fhgw_root_password}   alias=${tmp_alias}
    tafssh.Download File   remote_path=${initial_log_path}    local_path=${log_stored_path}   connection=${tmp_alias}

    _Delete Old Wireshark File In RUPROXY   initial_log_path=${initial_log_path}   container_id=${container_id}   alias=${alias}
    _Delete Old Wireshark File In FHGW   initial_log_path=${initial_log_path}    alias=${alias}


Get Current Host Time By Linux Cmd FHGW Container
    [Arguments]  ${container_id}  ${alias}=default
    [Documentation]    Get Current Host Time By Linux Cmd FHGW Container
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | container_id | yes | container_id |
    ...    | alias        | no | alias |
    ...
    ...    *RETURN VALUE*
    ...     time with unit of second.
    ...
    ...    Example
    ...    | ${sec} | Get Current Host Time By Linux Cmd FHGW Container |
    ${out}    issh.Execute     command=docker exec -it ${container_id} date +%s    alias=${alias}
    ${lines}  Get Lines Matching Regexp   ${out}   \\d{5,20}
    [Return]   ${lines}


Get Modified Time By Linux Cmd FHGW Container
    [Arguments]    ${filename}   ${container_id}  ${alias}=default
    [Documentation]    Get Modified Time By Linux Cmd inside FHGW Container
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | filename | yes | file name |
    ...    | container_id  | yes | container_id |
    ...    | alias    | no | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...     time with unit of second.
    ...
    ...    Example
    ...    | ${sec} | Get Modified Time By Linux Cmd FHGW Container | filename=/root/a.txt | container_id=${conainer_id} |
    ${out}    issh.Execute     command=docker exec -it ${container_id} stat --format=%Y ${filename}    alias=${alias}
    ${lines}  Get Lines Matching Regexp   ${out}   \\d{8,20}
    [Return]   ${lines}


Check File Existed In FHGW Container
    [Arguments]  ${filename}   ${container_id}   ${alias}=default
    [Documentation]    Check File Exist or not inside FHGW container
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | filename      | yes | file name |
    ...    | container_id | yes | container_id |
    ...    | alias        | no | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    return 1 if file exists, otherwise return 0
    ...
    ...    Example
    ...    | ${bExit} | Check File Existed In FHGW Container |  filename=/root/a.txt | container_id=123adadf23 | alias=default |
    ${out}    issh.Execute     command=docker exec -it ${container_id} ls ${filename}    alias=${alias}   check_result=${False}
    ${bExist}   Set Variable If     """No such file or directory""" in """${out}"""     0     1
    Return From Keyword If  ${bExist}==0   0
    ${bExist}   Set Variable If     """syntax error near unexpected token""" in """${out}"""     0     1
    [Return]   ${bExist}


_Remove All Temp File If Needed From FHGW
    [Arguments]  ${FolderName}    ${alias}
    ${out}     issh.Execute    command=ls -F -1 ${FolderName}   alias=${alias}
    ${curr_time}    Get Current Host Time By Linux Cmd Interactively  alias=${alias}
    ${lines}   Strip Prompt    content=${out}    return_list=True

    #delete Files 960 seconds Ago
    ${threshold}   Set Variable   3600

    FOR   ${file}    IN    @{lines}
        Continue For Loop If   '${file}'==''
        ${fullname}   Join Path   ${FolderName}   ${file}
        ${bExist}   Check File Existed In Linux Server Via Interactive SSH  filename=${fullname}   alias=${alias}
        Continue For Loop If   ${bExist}==0
        _Remove One Temp File If Needed Interactively   foldername=${FolderName}   filename=${file}
        ...   curr_time=${curr_time}     thrashold=${threshold}   alias=${alias}
    END


_Remove All Temp File If Needed From RUPROXY
    [Arguments]  ${FolderName}    ${container_id}  ${alias}
    ${out}    issh.Execute     command=docker exec -it ${container_id} ls -F -1 ${FolderName}    alias=${alias}
    ${curr_time}    Get Current Host Time By Linux Cmd FHGW Container   container_id=${container_id}  alias=${alias}
    ${lines}   Strip Prompt    content=${out}   return_list=True

    #delete Files 16 min ago
    ${threshold}   Set Variable   960

    FOR   ${file}    IN    @{lines}
        Continue For Loop If   '${file}'==''
        ${fullname}   Join Path   ${FolderName}   ${file}
        ${bExist}   Check File Existed In FHGW Container    ${fullname}   container_id=${container_id}   alias=${alias}
        Continue For Loop If   ${bExist}==0
        _Remove One Temp File If Needed FHGW Container   foldername=${FolderName}   filename=${file}
        ...   curr_time=${curr_time}     thrashold=${threshold}   container_id=${container_id}  alias=${alias}
    END


_Remove One Temp File If Needed FHGW Container
    [Arguments]    ${foldername}   ${filename}    ${curr_time}    ${thrashold}   ${container_id}  ${alias}
    # ${foldername}:  /tmp/tmp_wireshark
    ${fullname}    Join Path    ${foldername}     ${filename}
    ${filemtime}   Get Modified Time By Linux Cmd FHGW Container   filename=${fullname}  container_id=${container_id}  alias=${alias}
    ${delta}    Evaluate   ${curr_time}-${filemtime}
    ${bDeleteIt}    Set Variable If    ${delta}>${thrashold}    1      0
    Run Keyword If   ${bDeleteIt}==1
      ...  issh.Execute     command=docker exec -it ${container_id} rm -rf ${fullname}    alias=${alias}

_Delete Old Wireshark File In FHGW
    [Arguments]  ${initial_log_path}   ${alias}
    ${res}   issh.Execute  command=ls -l /tmp/tmp_wireshark   alias=${alias}
    Log   ${res}
    issh.Execute  command=rm -f ${initial_log_path}     alias=${alias}
    _Remove All Temp File If Needed From FHGW   FolderName=/tmp/tmp_wireshark   alias=${alias}


_Delete Old Wireshark File In RUPROXY
    [Arguments]  ${initial_log_path}   ${container_id}  ${alias}
    ${out}    issh.Execute     command=docker exec -it ${container_id} rm -f ${initial_log_path}    alias=${alias}
    _Remove All Temp File If Needed From RUPROXY   FolderName=/tmp/tmp_wireshark   container_id=${container_id}  alias=${alias}
