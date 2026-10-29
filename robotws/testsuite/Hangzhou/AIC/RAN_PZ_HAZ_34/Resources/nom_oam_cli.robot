*** Settings ***
Documentation
...   author: Huang Fen
...   contact: fen.huang@nokia-sbell.com




*** Variables ***


*** Keyword ***
SSH To NOM Server
    [Documentation]    Ssh to work nom edge node. which support NOM server configuration redundancy,
    ...                is used to replace 'SSH To NOM'
    ...                private rsa key should be prepare in test line config folder with file name id_rsa.
    ...  author: chris.l.cao@nokia-sbell.com

    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    connection alias
    ...
    ...    Example
    ...    | ${alias} | SSH To NOM  Server |
    ...
    log to console    SSH To NOM Server
    ${nom_sftp_information}   Get NOM SFTP Information

    ${alias}=  get unique id
    ${key_file}   set variable  ${nom_sftp_information["ssh_key_file"]}
    File should exist    ${key_file}
    issh.Connect to    ip=${nom_sftp_information["ssh_ip"]}
    ...                port=22
    ...                username=${nom_sftp_information["ssh_user"]}
    ...                password=""
    ...                prompt=\\[cloud-user@\\S+.*\\]\\$|\\[root@\\S+.*\\]#|\\[core@\\S+\\s\\S+\\]
    ...                timeout=600
    ...                alias=${alias}
    ...                keyfile=${key_file}
    ${output}=  issh.execute  hostname  check_result=${False}  alias=${alias}
    #${output}=  Convert to lowercase  ${output}
    #should contain   ${output}   cnms   ssh to nom failed!
    [Return]   ${alias}


NMS Port Should Listen In NE
    [Arguments]   ${ne_type}=vdu  ${security_mode}=No TLS   ${gnb_index}=0   ${vdu_index}=0  ${fhgw_index}=0
    [Documentation]    Firewall Between NOM and NE Should Be Good
    ...  author:             chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   21.2.2022,chris.l.cao@nokia-sbell.com, initialization version
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ne_type  |  No  |  Which type of ne will be integrated, can be cu/vcu/vdu/fhgw, vdu in default   |
    ...    | security_mode | no | security_mode, 'No TLS' or TLS, default is 'No TLS'  |
    ...    | gnb_index  |  No  |  cu index, should be 0, 1...  |
    ...    | vdu_index  |  No  |  vdu index under specified cu   |
    ...    | fhgw_index |  No  |  fhgw index under specified vdu   |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...   | NMS Port Should Listen In NE | ne_type=vdu  | security_mode=No TLS |
    ...   | NMS Port Should Listen In NE | ne_type=vdu  | security_mode=TLS |
    ...   | NMS Port Should Listen In NE | ne_type=vcu  | security_mode=No TLS |
    ...   | NMS Port Should Listen In NE | ne_type=vcu  | security_mode=TLS |
    ...
    ${port_list}  Run Keyword If   "${security_mode}"=="No TLS"   Create List  8080
       ...   ELSE   Create List  8443
    ${ne_type}  Set Variable If  "${ne_type}"=="cu"    vcu  ${ne_type}
    ${target_ip}   Run Keyword If   "${ne_type}"=="vdu"
    ...   Port Should Listen In VDU Container  port_list=${port_list}  ctr_abbr=oamagent   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ...    ELSE IF   "${ne_type}"=="vcu"
    ...   Port Should Listen In VCU Container  port_list=${port_list}  ctr_abbr=oamagent   gnb_index=${gnb_index}
#    ...    ELSE IF   "${ne_type}"=="fhgw"
#    ...   Confirm Ports Are Listening In FHGW   gnb_index=${gnb_index}    vdu_index=${vdu_index}   fhgw_index=${fhgw_index}
#    ...    ELSE   Fail  Unknown ne_type:${ne_type}!




SSH To NOM
    [Documentation]    Ssh to work nom edge node.
    ...                private rsa key should be prepare in test line config folder with file name id_rsa.
    ...  author:             jie.8.liu@nokia-sbell.com
    ...  modified by:        <17-May-2021>, <j9liu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    connection alias
    ...    Example
    ...    | SSH To NOM |    |
    Log To Console   This KW 'SSH To NOM' was deprecated! Please use 'SSH To NOM Server'
    log to console    Start ssh to nom
    ${result}  run keyword and return status  SSH To the Primary NOM
    ${alias} =   run keyword if  "${result}"=="True"   SSH To the Primary NOM
    ...  ELSE       SSH to Secondary NOM
    [Return]   ${alias}


SSH To the Primary NOM
    [Documentation]    Ssh to nom edge node.
    ...                private rsa key should be prepare in test line config folder with file name id_rsa.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <20-Oct-2020>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    connection alias
    ...    Example
    ...    | SSH To NOM |    |
    log to console    ssh to nom
    ${alias}=  get unique id
    ${key_file}=   set variable  ${CURDIR}/nom/id_rsa
    File should exist    ${key_file}
    issh.Connect to    ip=${tl.nms.nom.ssh_connections_info[0].addr}
    ...                port=22
    ...                username=${tl.nms.nom.ssh_connections_info[0].username}
    ...                password=""
    ...                prompt=\\[cloud-user@\\S+.*\\]\\$|\\[root@\\S+.*\\]#
    ...                timeout=60
    ...                alias=${alias}
    ...                keyfile=${key_file}
    ${output}=  issh.execute  hostname  check_result=${False}  alias=${alias}
    ${output}=  Convert to lowercase  ${output}
    should contain   ${output}   cnms   ssh to nom failed!
    [Return]   ${alias}


SSH To Secondary NOM
     [Documentation]    Ssh to backup NOM.
    ...                private rsa key should be prepare in test line config folder with file name id_rsa.
    ...  author:             jie.8.liu@nokia-sbell.com
    ...  modified by:        <17-May-2021>, <j9liu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    connection alias
    ...    Example
    ...    | SSH To NOM |    |
    log to console   Start ssh to backup NOM
    ${alias}=  get unique id
    ${key_file}=   set variable  ${CURDIR}/nom/id_rsa_nom10
    File should exist    ${key_file}
    issh.Connect to    ip=${NOM_10_SSH_IP}
    ...                port=22
    ...                username=${NOM_10_SSH_USERNAME}
    ...                password=""
    ...                prompt=\\[cloud-user@\\S+.*\\]\\$|\\[root@\\S+.*\\]#
    ...                timeout=60
    ...                alias=${alias}
    ...                keyfile=${key_file}
    ${output}=  issh.execute  hostname  check_result=${False}  alias=${alias}
    ${output}=  Convert to lowercase  ${output}
    should contain   ${output}   cnms   ssh to nom10 success!
    [Return]   ${alias}


Connect To NOM Sftp Server
    [Documentation]    Connect To NOM Sftp Server
    ...  This keyword is used to get pm log file from nom sftp server.
    ...  author:            chris.l.cao@nokia-sbell.com
    ...  modified by:        <01-02-2021>, <horao>, <initial created>
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | None |
    ...
    ...    *RETURN VALUE*
    ...    alias to NOM sftp server connection
    ...
    ...    Example
    ...    | ${alias} | Connect To NOM Sftp Server |
    ...    | ${out} | issh.Execute | command=ls -l | alias=${alias} |
    ...    | ${out} | issh.Execute | command=get a.txt | alias=${alias} |
    ...    | disconnect interactive connection | alias=${alias} |
    ...
    ${alias}   get unique id
    Connect To UTE Locally  alias=${alias}
    ${old_prompt}   issh.get_prompt    alias=${alias}
    ${out}   issh.set_prompt   prompt_str=${old_prompt}|password:|sftp>     alias=${alias}

    ${nom_sftp_information}   Get NOM SFTP Information
    ${nom_sftp_user}   Set Variable   ${nom_sftp_information["pm_sftp_username"]}
    ${nom_sftp_password}   Set Variable   ${nom_sftp_information["pm_sftp_password"]}
    ${nom_sftp_server}   Set Variable   ${nom_sftp_information["pm_sftp_ip"]}

    ${output}=  issh.execute  sftp ${nom_sftp_user}@${nom_sftp_server}  check_result=${False}  alias=${alias}
    ${out}   run keyword if   """password:""" in """${output}"""  issh.execute  ${nom_sftp_password}  check_result=${False}  alias=${alias}
    ${out}   issh.set_prompt   prompt_str=${old_prompt}|sftp>     alias=${alias}

    [Return]  ${alias}





NOM Get Pm Files From Sftp Server For Rest Integration
    [Arguments]  ${ne_id}   ${local_dir}=/tmp  ${ne_type}=VDU  ${date}=${None}
    [Tags]  NOM_PM
    [Teardown]   run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]    get pm file from nom sftp sever
    ...  This keyword is used to get pm file from nom sftp server.
    ...  author:             hongping.rao@nokia-sbell.com
    ...  modified by:        <01-02-2021>, <horao>, <initial created>
    ...    1.11.2021, chris.l.cao@nokia-sbell.com, support REST integration
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  ne_id  |  Yes  |  ne_id to define which pm log files will be collected from server  |
    ...    |  local_dir  |  No  |  local directory to store log files, default is /tmp   |
    ...    |  ne_type  |  No  |  ne type, such as: VDU, FHGW, default is VDU |
    ...    |  date  |  No  |  get PM log file according to the log date, default is today |
    ...
    ...    *RETURN VALUE*
    ...    local pm file name list
    ...
    ...    Example
    ...    | ${pm_files_list} | NOM Get Pm Files From Sftp Server |  ne_id=5233 | local_dir=/tmp | ne_type=VDU |
    ...
    ${alias}   Connect To NOM Sftp Server
    ${str_nom_date}   Get Date Of NOM Server
    ${date}  set variable if   ${date}   ${date}  ${str_nom_date}

    Log To Console  date:${date}

    ${sub_folder}   Set Variable If   "${ne_type}"=="VDU"   MRBTS   "${ne_type}"=="VCU"   MRBTS  unknown
    Run Keyword If   "${sub_folder}"=="unknown"    Not support ${ne_type}!

    ${nom_sftp_information}   Get NOM SFTP Information
    ${nom_sftp_root_folder}   Set Variable   ${nom_sftp_information["pm_sftp_root_path_rest"]}

    ${remote_dir}  OperatingSystem.Join Path  ${nom_sftp_root_folder}  ${sub_folder}    ${date}   ${ne_id}
    ${out}  issh.execute   get ${remote_dir}/*.* ${local_dir}   check_result=${False}  alias=${alias}

    ${empty_list}  create list
    return from keyword if  "not found." in """${out}"""    ${empty_list}

    #Get next day
    ${current_day}   Convert Date 	${date}	  exclude_millis=yes 	date_format=%Y%m%d
    ${next_day}      Add Time To Date   ${current_day}   1 day
    ${next_date_str} 	Convert Date 	${next_day} 	result_format=%Y%m%d
    Log To Console   next_date:${next_date_str}

    ${remote_dir}  OperatingSystem.Join Path  ${nom_sftp_root_folder}  ${sub_folder}    ${next_date_str}   ${ne_id}
    ${out}  issh.execute   get ${remote_dir}/*.* ${local_dir}   check_result=${False}  alias=${alias}

    ${res}    list_files_in_directory    ${local_dir}
    [Return]    ${res}


Get Date Of NOM Server
    [Teardown]  run keyword and ignore error  disconnect interactive connection    alias=${alias}
    [Documentation]    Get Date Of NOM Server
    ...  This keyword is used to get pm log file from nom sftp server.
    ...  author:            chris.l.cao@nokia-sbell.com
    ...  modified by:        <01-02-2021>, <horao>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    | None |
    ...
    ...    *RETURN VALUE*
    ...    Date Of NOM Server
    ...
    ...    Example
    ...    | ${str_nom_date} | Get Date Of NOM Server |
    ...
    ${alias}   SSH To NOM Server
    ${date}   issh.Execute   date -I   check_result=${False}   alias=${alias}
    ${date_str}   Replace String   ${date}   -   ${EMPTY}   count=2
    ${date_str_new}   Get Substring   ${date_str}   1   9
    [Return]  ${date_str_new}



Connect to Appointed Nom
    [Arguments]   ${NOM_label}
    [Documentation]    Connect to Appointed Nom
    ...    *Author:*  rui.3.li@nokia-sbell.com
    ...    *Modify History*
    ...    | who | date | what and how |
    ...    | r3li | 2022-2-22 | init create |
    ...    | xuhuilin | 2022-10-14 | remove the check as no output including cnms for nom22|
    ...    *Arguments Description*
    ...    | input arg | Man. | Description |
    ...    | NOM_label | Yes | Nom label, such as NOM4,NOM10,NOM13 |
    ...    *Example*
    ...    | Connect to Appointed Nom | NOM13 |

    ${NOM_info}    Get Appointed Nom Info By Label    ${nom_label}
    ${alias}=  get unique id
    ${key_file}=   set variable  ${CURDIR}/${NOM_info}[ssh_key_file]
    File should exist    ${key_file}
    ${user_name}    set variable    ${NOM_info["main_info"].ssh_connections_info[0].username}
    issh.Connect to    ip=${NOM_info["main_info"].ssh_connections_info[0].addr}
    ...                port=22
    ...                username=${user_name}
    ...                password=""
    ...                prompt=\\[${user_name}@\\S+.*\\]\\$|\\[root@\\S+.*\\]#
    ...                timeout=60
    ...                alias=${alias}
    ...                keyfile=${key_file}
    ${output}=  issh.execute  hostname  check_result=${False}  alias=${alias}
    [Return]    ${alias}


DownLoad SW Package To Nom By SSH
    [Arguments]   ${NOM_label}    ${release_name}    ${build_version}
    [Documentation]    DownLoad SW Package To Nom By SSH
    ...    *Author:*  rui.3.li@nokia-sbell.com
    ...    *Modify History*
    ...    | who | date | what and how |
    ...    | r3li | 2022-2-22 | init create |
    ...    | huilxu | 2022-08-15 | modify to hangzhou artifactory |
    ...    | huilxu | 2022-10-27 | modify to espoo1 artifactory and adaption for vDUCNF00/vCUCNF00 |
    ...    | huilxu | 2022-10-31 | correct the error of download url |
    ...    *Arguments Description*
    ...    | input arg | Man. | Description |
    ...    | NOM_label | Yes | Nom label, such as NOM4,NOM10,NOM13 |
    ...    | release_name | Yes | string, release name, such as vDUCNF |
    ...    | build_version | Yes | build version, such as 14.300.431 |
    ...    *Example*
    ...    | Nom Rest Login | NOM13 |
    ...    | ${file_path} | DownLoad SW Package To Nom By SSH | NOM13 | vDUCNF22R2 | 14.300.432 |
    log to console   DownLoad SW Package To Nom By SSH
    ${alias}    Connect to Appointed Nom    ${NOM_label}
    ${file_package_name}   set variable    sw_package
    issh.execute   mkdir ${file_package_name}   check_result=${False}  alias=${alias}
    ${out}    issh.execute    pwd   check_result=${False}  alias=${alias}
    ${current_file_path}   Strip Prompt    ${out}
    ${download_whole_url}  set variable   ${PACKAGE_LINK_ESPOO}/${release_name}/${release_name}_${build_version}/${release_name}_${build_version}.zip
    ${download_cmd}   set variable    wget -P ${file_package_name} ${download_whole_url}
    issh.set_timeout    600    alias=${alias}
    issh.execute   ${download_cmd}   check_result=${False}  alias=${alias}
    ${full_file_path}   set variable    ${current_file_path}/${file_package_name}/${release_name}_${build_version}.zip
    _Get Full File Path For 9544    ${build_version}    ${full_file_path}   alias=${alias}
    [Return]   ${full_file_path}


_Get Full File Path For 9544
    [Arguments]   ${build_version}    ${full_file_path}   ${alias}=${None}
    ${SW_version_list1}    split string  ${build_version}    .
    ${stream_name}    Set Variable    ${SW_version_list1[0]}.${SW_version_list1[1]}
    ${key_list}   Get Dictionary Keys   ${PACKAGE_PRE_MAPPING}
    ${index}   Get Index From List   ${key_list}   ${stream_name}
    ${file_path}   ${file_name}    Split Path   ${full_file_path}
    ${unzip_command}    Set Variable   unzip ${full_file_path} -d ${file_path}
    Run Keyword If   (${index}<=${2} or ${index}>${10}) and '${alias}'!='${None}'    issh.execute
    ...   command=${unzip_command}  alias=${alias}
    ...   ELSE IF    (${index}<=${2} or ${index}>${10}) and '${alias}'=='${None}'   OperatingSystem.Run  command=${unzip_command}


Import SW Package to Nom By SSH
    [Arguments]    ${NOM_label}    ${release_name}    ${build_version}   ${file_path}   ${ne_type}=MRBTS
    [Documentation]    Import SW Package to Nom By SSH
    ...    *Author:*  rui.3.li@nokia-sbell.com
    ...    *Modify History*
    ...    | who | date | what and how |
    ...    | r3li | 2022-2-22 | init create |
    ...    | r3li | 2022-5-25 | correct error |
    ...    | r3li | 2022-8-16 | remove hardcode and disconnect NOM in teardown |
    ...    | huilxu | 2022-10-14 | change to neo8922 and change the script execution way |
    ...    *Arguments Description*
    ...    | input arg | Man. | Description |
    ...    | NOM_label | Yes | Nom label, such as NOM4,NOM10,NOM13 |
    ...    | release_name | Yes | string, release name, such as vDUCNF |
    ...    | build_version | Yes | build version, such as 14.300.431 |
    ...    | file_path | Yes | file path of sw package in nom node eg |
    ...    *Example*
    ...    | Nom Rest Login | NOM13 |
    ...    | ${file_path} | DownLoad SW Package To Nom By SSH | NOM13 | vDUCNF22R2 | 14.300.432 |
    ...    | Import SW Package to Nom By SSH | NOM13 | vDUCNF22R2 | 14.300.432 | ${file_path} |
    ${NOM_info}    Get Appointed Nom Info By Label    ${nom_label}
    ${http_addr}   set variable   ${NOM_info["main_info"].https_user_mgmt_info.addr}
    ${username}    set variable   ${NOM_info["main_info"].https_main_info.username}
    ${pwd}    set variable   ${NOM_info["main_info"].https_main_info.password}
    ${api_http_addr}    set variable   ${NOM_info["main_info"].https_rest_info.addr}
    ${alias}    Connect to Appointed Nom    ${NOM_label}
    log to console    Import SW Package to Nom
    ${file_path}   ${file_name}   Split Path   ${file_path}
    ${script_name}    set variable    import_pkg.sh

    ${login_command_1}   set variable   export ACCESS_TOKEN=$( curl -x "" -k -X POST "${http_addr}/auth/realms/NEO/protocol/openid-connect/token"
    ${login_command_2}   set variable   -H "Content-Type: application/x-www-form-urlencoded" -d "grant_type=password"
    ${login_command_3}   set variable   -d "client_id=neo8922-test-client" -d "client_secret=hczKJEvJkrB2kqgSOluwpHwy5tAKGL5q"
    ${login_command_4}   set variable   -d "scope=openid" -d "username=${username}" -d "password=${pwd}" | jq -r ".access_token")
    ${login_command}   set variable   ${login_command_1} ${login_command_2} ${login_command_3} ${login_command_4}
    issh.execute    echo -e '${login_command}' > ${file_path}/${script_name}    check_result=${False}  alias=${alias}

    ${import_command_1}    set variable    curl -x "" -v -k -H "Authorization: Bearer $ACCESS_TOKEN" -H "X-NOM-NeType: ${ne_type}"
    ${import_command_2}    set variable    -H "X-NOM-NeSwVersion: ${release_name}_${build_version}"
    ${import_command_3}    set variable    -H "X-NOM-Filename: ${release_name}_${build_version}.zip" -H "Content-Type: application/octet-stream"
    ${import_command_4}    set variable
    ...  --data-binary @${file_path}/${release_name}_${build_version}.zip -X POST "${api_http_addr}/ui/plan-operations/api/neSoftwareImport"
    ${import_command}    set variable    ${import_command_1} ${import_command_2} ${import_command_3} ${import_command_4}
    issh.execute    echo -e '${import_command}' >> ${file_path}/${script_name}    check_result=${False}  alias=${alias}

    ${output}    issh.Execute    command=nohup bash ${file_path}/${script_name} &   alias=${alias}
    ${output0}   issh.Execute    command=ls   alias=${alias}
    ${output}   Strip Prompt   ${output}
    ${pid}  Get Regexp Matches  ${output}   .*\\[\\d+\\]\\s+(\\d+)$   1
    ${pid}  set variable    ${pid[0]}

    Wait Until Process Disappear  pid=${pid}  alias=${alias}  duration=600  interval=60

    log to console    start check
    FOR   ${i}  IN RANGE  ${6}
       log to console   check times:${i}
       ${res}  Run Keyword and ignore error   VDU Chart Build Should Be In NOM    ${release_name}    ${build_version}    ne_type=${ne_type}
       Exit For Loop If   '${res}[0]'=='PASS'
       sleep   240
    END
    VDU Chart Build Should Be In NOM    ${release_name}    ${build_version}    ne_type=${ne_type}
    [Teardown]    Run Keywords   issh.execute   rm -rf ${file_path}/*   check_result=${False}  alias=${alias}   AND
    ...    issh.disconnect   alias=${alias}
