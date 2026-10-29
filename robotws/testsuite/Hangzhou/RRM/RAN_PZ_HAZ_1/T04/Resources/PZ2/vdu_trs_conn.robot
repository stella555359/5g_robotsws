*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   vdu_trs_conn.robot
...   vdu connection related KW.








*** Keywords ***
Wait Until Process Disappear
    [Arguments]  ${pid}   ${alias}   ${duration}=1200  ${interval}=2
    [Documentation]    Wait Until Process Disappear
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | pid       |  yes | pid |
    ...    | alias     |  yes | alias |
    ...    | duration     |  no | duration, default is 1200 |
    ...    | interval     |  no | interval, default is 5 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Wait Until Process Disappear | 123 |  alias=myalias |
    ...
    wait until keyword succeeds   ${duration}   ${interval}   _Wait Until Process Disappear Once   pid=${pid}   alias=${alias}


_Wait Until Process Disappear Once
    [Arguments]  ${pid}   ${alias}
    ${r}  ${out}  run keyword and ignore error  issh.Execute   command=ps -p ${pid} -f   alias=${alias}
    should be true  "${r}"=="FAIL"


Get Container ID From Pod Abbr
    [Arguments]   ${pod_abbr}   ${ctr_abbr}   ${alias}=default   ${gnb_index}=0   ${vdu_index}=0
    [Documentation]    Get Container ID
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: 15.7.2022,lingting.sun@nokia-sbell.com, adaption for multi gnb
    ...    |  Input Parameters | Man. | Description |
    ...    | ns              | Yes | namespace |
    ...    | container  | yes | container_abbr |
    ...    | alias   | no | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    get container id for OCP
    ...
    ...    Example
    ...    | ${alias} | Get Unique Id |
    ...    | Connect To K8s Master Interactively | alias=${alias} |
    ...    | ${container_id} | Get Container ID  | container=oamfh | alias=${alias} |
    ...    | Disconnect Interactive Connection | alias=${alias} |
    ...
    ${container_prefix}  Get Container Name Prefix  vdu_index=${vdu_index}
    ${full_container_name}  Set Variable  ${container_prefix}${ctr_abbr}
    ${full_pod_name}   Get Full Pod Name By Pod Abbreviation Interactively   pod_abbr=${pod_abbr}
    ...   gnb_index=${gnb_index}   vdu_index=${vdu_index}   alias=${alias}

#    ${full_container_name}     Get Full Container Name By Container Abbreviation  ctr_abbr=${ctr_abbr}
#    ...    vdu_index=${vdu_index}    gnb_index=${gnb_index}

    ${ns}   Get Vdu Namespace From Testline    vdu_index=${vdu_index}    gnb_index=${gnb_index}
#    kubectl describe pods po-cran1-oamext-0 -n cran1 |grep "ctr-cran1-nwmgmt:" -A 1|grep -i "container id"|awk -F "//" '{print $2}'
    ${ssh_command}   Set Variable   kubectl describe pods ${full_pod_name} -n ${ns} |grep "${full_container_name}:" -A 1
    ${ssh_command}  Set Variable   ${ssh_command}|grep -i "container id"|awk -F "//" '{print $2}'

    ${out}  issh.Execute  command=${ssh_command}  alias=${alias}
    ${out}  Strip Prompt  ${out}

    ${container_id}   Set Variable  ${out.strip()}
    [Return]  ${container_id}


Get PID For Container From Pod Abbr
    [Arguments]   ${pod_abbr}   ${ctr_abbr}   ${alias}=default   ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   Get PID For Container
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: 15.7.2022,lingting.sun@nokia-sbell.com, adaption for multi gnb
    ...    |  Input Parameters | Man. | Description |
    ...    | ns              | Yes | namespace |
    ...    | container  | yes | container_abbr |
    ...    | alias   | no | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    get container id for OCP
    ...
    ...    Example
    ...    | ${alias} | Get Unique Id |
    ...    | Connect To K8s Master Interactively | alias=${alias} |
    ...    | ${pid} | Get PID For Container  | container=oamfh | alias=${alias} |
    ...    | Disconnect Interactive Connection | alias=${alias} |
    ...
    ${container_id}   Get Container ID From Pod Abbr   pod_abbr=${pod_abbr}  ctr_abbr=${ctr_abbr}  alias=${alias}
        ...   gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${ssh_command}   Set Variable   sudo crictl inspect --output yaml ${container_id}| grep 'pid:'|awk -F ':' '{print $2}'
    ${out}  issh.Execute  command=${ssh_command}  alias=${alias}
    ${out}  Strip Prompt  ${out}

    ${pid}   Set Variable  ${out.strip()}
    [Return]  ${pid}


Get Host Name
    [Arguments]  ${alias}=default
    ${out}   issh.Execute   command=hostname   alias=${alias}
    ${lines}  Split To Lines  ${out}
    ${hostname}   Set Variable   ${lines[1].strip()}
    [Return]  ${hostname}


Disconnect All SSH Connections
    Run Keyword And Ignore Error   Disconnect Interactive Connections
    Run Keyword And Ignore Error   tafssh.Reset Cache




Get Current User Name Interactively
    [Arguments]  ${alias}=default
    [Documentation]  Get Current User Name Interactively
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | alias       |  no | alias, defaut is default |
    ...
    ...    *RETURN VALUE*
    ...    current user name who logins K8S node
    ...
    ...    Example
    ...    | ${current_user_name} | Get Current User Name Interactively |
    ...
    ${out}   issh.Execute    command=ls -l /tmp  check_result=${False}  alias=${alias}
    ${out}   issh.Execute   command=whoami  check_result=${False}  alias=${alias}
    ${whoami}   Strip Prompt  ${out}
    ${whoami}   Set Variable  ${whoami.replace("\x1b[?2004l\r","")}
    [Return]   ${whoami}



Get A Remote File
    [Arguments]   @{parameter_list}
    [Teardown]  run keyword and ignore error   disconnect interactive connection   alias=${alias_admin}
    [Documentation]   create a temparary file in remote server and return full file name,
    ...    this file will keep 3 hours then it will be removed automatically
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | parameter_list    | yes | including subfolder name or file name, and alias, please see examples  |
    ...
    ...    *RETURN VALUE*
    ...   Full temparary file name with folders name
    ...
    ...    Example
    ...   | ${alias}   | Get Unique Id |
    ...   | connect to k8s master with tenant interactively | alias=${alias} |
    ...
    ...   return /tmp/tmp_taic/<suitename>/<casename>/2020_08_06_04_58_01/folder1/folder2/xxxxxxx_a.txt
    ...   | ${remote_file_name} | Get A Remote File |  folder1 | folder2 | a.txt | alias=${alias} |
    ...
    ...   return /tmp/tmp_taic/<suitename>/<casename>/2020_08_06_04_58_01/folder1/a.log
    ...   | ${remote_file_name} | Get A Remote File | folder1 | xxxxxxx_a.log | alias=${alias} |
    ...
    ...
    ...   | Connect To vDU Node Interactively | pod_abbr=oam |
    ...   return /tmp/tmp_taic/<suitename>/<casename>/2020_08_06_04_58_01/folder1/folder2/xxxxxxx_c.txt
    ...   | ${remote_file_name} | Get A Remote File |  folder1 | folder2 | c.txt |
    ...

    ${non_key_value_pair_list}   ${key_value_dict}   run keyword if  ${parameter_list.__len__()}>0
       ...   _Parse Input Parameter According To Seperator   =   @{parameter_list}
    ${non_key_value_pair_list}  run keyword if  "${non_key_value_pair_list}"=="${None}"   create list
       ...   ELSE   set variable  ${non_key_value_pair_list}
    ${key_value_dict}  run keyword if  "${key_value_dict}"=="${None}"   create dictionary
       ...   ELSE   set variable  ${key_value_dict}

    ${key_value_dict_keys}   evaluate  list(${key_value_dict})

    ${alias}   set variable if   "alias" in "${key_value_dict_keys}"   ${key_value_dict["alias"]}   default
    Run Keyword If  "alias" in "${key_value_dict_keys}"   Remove From Dictionary   ${key_value_dict}   alias
    Run Keyword If  "alias" in "${key_value_dict_keys}"   Remove Values From List   ${key_value_dict_keys}   alias

    #${base_folder0}  set variable   /tmp/tmp_taic
    ${ns}   get vdu namespace from testline
    ${cu_ns}=   Get CU Namespace From TestLine
    ${base_folder0}  set variable   /tmp/tmp_taic_${ns}_${cu_ns}

    #set full permission
    ${alias_admin}   get unique id
    connect to k8s master interactively  alias=${alias_admin}
    ${out}  issh.Execute  command=sudo mkdir -p ${base_folder0}    alias=${alias_admin}
    ${out}  issh.Execute  command=sudo chmod -R 777 ${base_folder0}    alias=${alias_admin}

    ${base_folder}  _Get Remote Log Path   base_folder=${base_folder0}

    ${subfolders_or_file_name}  set variable  ${non_key_value_pair_list}
    ${length}   Get Length  ${subfolders_or_file_name}
    issh.Execute  command=mkdir -p ${base_folder}   check_result=${False}   alias=${alias}

#    Clear Unused Remote Files    folder_name=${base_folder0}  time_window=10800   alias=${alias}

    ${tmp_file}   Get Unique ID   precise=FORMAT_DATETIME
    ${full_file_name}   Run Keyword If  ${length}>0   OperatingSystem.Join Path   ${base_folder}   @{subfolders_or_file_name}
    ...   ELSE   OperatingSystem.Join Path   ${base_folder}   ${tmp_file}

    ${path}  ${file}   OperatingSystem.Split Path   ${full_file_name}
    issh.Execute  command=mkdir -p ${path}   check_result=${False}   alias=${alias}

    ${full_file_name}   Run Keyword If  ${length}>0   Operatingsystem.Join Path   ${path}   ${tmp_file}_${file}
       ...   ELSE   set variable   ${full_file_name}
    issh.Execute  command=touch ${full_file_name}   check_result=${False}   alias=${alias}
    #issh.Execute  command=chmod -R 777 ${base_folder}  check_result=${False}   alias=${alias}
    _Get A Remote File Set Full Permission    folder_name=${base_folder}   alias=${alias}

    [Return]   ${full_file_name}


_Get A Remote File Set Full Permission
    [Arguments]  ${folder_name}     ${alias}=default
    [Documentation]   Clear Unused Remote Files under specified folder
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | folder_name      | yes | folder_name to be scanned  |
    ...    | alias            | no | alias, default is default|
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ${current_user_name}   Get Current User Name Interactively   alias=${alias}

    ${vdu_k8s_master_ssh_connection_info}   Get K8s Admin SSH Connection Info
    ${vdu_k8s_tenant_ssh_connection_info}   Get K8s Tenant SSH Connection Info

    ${host_type}  Get Host Type  alias=${alias}
    run keyword if  "${host_type}"=="OE_SERVER_CONTROLLER" and "${current_user_name}"=="${vdu_k8s_tenant_ssh_connection_info["username"]}"
    ...    _Get A Remote File Set Full Permission On OE Server With Admin   folder_name=${folder_name}
    return from keyword if  "${host_type}"=="OE_SERVER_CONTROLLER" and "${current_user_name}"=="${vdu_k8s_tenant_ssh_connection_info["username"]}"

    run keyword if  "${host_type}"=="OE_SERVER_CONTROLLER" and "${current_user_name}"=="${vdu_k8s_master_ssh_connection_info["username"]}"
    ...    _Get A Remote File Set Full Permission On OE Server With Admin   folder_name=${folder_name}  alias=${alias}
    return from keyword if  "${host_type}"=="OE_SERVER_CONTROLLER" and "${current_user_name}"=="${vdu_k8s_master_ssh_connection_info["username"]}"

    Fail   Unknown host type!


_Get A Remote File Set Full Permission On OE Server With Admin
    [Arguments]  ${folder_name}    ${alias}=${EMPTY}
    [Teardown]  run keyword if   "${alias}"=="${EMPTY}"   disconnect interactive connection  alias=${alias_new}
    [Documentation]   Clear Unused Remote Files under specified folder
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | folder_name      | yes | folder_name to be scanned  |
    ...    | alias            | no | alias, default is default|
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ${alias_new}   run keyword if   "${alias}"=="${EMPTY}"  get unique id
      ...   ELSE  set variable  ${alias}
    run keyword if   "${alias}"=="${EMPTY}"   connect to k8s master interactively  alias=${alias_new}
    ${vdu_k8s_master_ssh_connection_info}   Get K8s Admin SSH Connection Info
    ${admin_username}  set variable  ${vdu_k8s_master_ssh_connection_info["username"]}
    issh.Execute  command=sudo chmod -R 777 ${folder_name}  check_result=${False}   alias=${alias_new}
    issh.Execute  command=sudo chown -R ${admin_username}:${admin_username} ${folder_name}  check_result=${False}   alias=${alias_new}


Get Host Type
    [Arguments]  ${alias}=default
    [Documentation]   Get Host Type
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | alias            | no | alias, default is default|
    ...
    ...    *RETURN VALUE*
    ...  OE_SERVER_CONTROLLER or GENERAL_LINUX_SERVER
    ...
    ${prompt_oe_server_NCS}  set variable   \\[core@\\S+\\s\\S+\\]\\$
    ${prompt_oe_server_NCS}  set variable   ${prompt_oe_server_NCS}|\\[cranuser\\d+@\\S+\\s\\S+\\s+\\S+\\]\\$
    ${prompt_oe_server_NCS}  set variable   ${prompt_oe_server_NCS}|\\[cranuser\\d+@\\S+\\s\\S+\\]\\$

    ${prompt_oe_server_OCP}  set variable   \\[core@\\S+\\s\\S+\\]\\$
    ${prompt_oe_server_NCS}  set variable   ${prompt_oe_server_NCS}|${prompt_oe_server_OCP}

    ${out}   issh.Execute   command=hostname  alias=${alias}
    ${matches}   get regexp matches  ${out}   \\[root@controller\\(FHGW.*\\).*\\]
    return from keyword if  ${matches}   FHGW

    ${matches}   get regexp matches  ${out}   \\[core@controller-\\d.*\\]|\\[cranuser\\d+@controller-\\d.*\\]
    return from keyword if  ${matches}   OE_SERVER_CONTROLLER

    ${matches}   get regexp matches  ${out}   ${prompt_oe_server_NCS}
    return from keyword if  ${matches}   OE_SERVER_CONTROLLER

    ${matches}   get regexp matches  ${out}   \\[cloudadmin@compute-\\d+.*\\]
    return from keyword if  ${matches}   OE_SERVER_COMPUTER

    [Return]  GENERAL_LINUX_SERVER



_Get Remote Suite Log Path
    [Arguments]  ${base_folder}
    ${result}    Run Keyword And Ignore Error    Variable Should Exist    ${START_TIME}
    run keyword if  "${result[0]}"!="PASS"   Fail  START_TIME is not initialzed! Please call 'Aic Common Setup' firstly.

    ${concated_suite_name}    Replace String    ${SUITE NAME}    ${SPACE}    _
    ${concated_suite_name}    Set Variable    ${concated_suite_name.replace("(", "").replace(")", "").replace("&", "")}
    ${timestamp}     Set Variable    ${START_TIME.replace(" ", "_").replace("-", "_").replace(":", "_")}
    ${suite_log_path}    OperatingSystem.Join Path    ${base_folder}    ${concated_suite_name}   ${timestamp}
    [Return]    ${suite_log_path}


_Get Remote Case Log Path
    [Arguments]  ${base_folder}
    ${result}    Run Keyword And Ignore Error    Variable Should Exist    ${START_TIME}
    run keyword if  "${result[0]}"!="PASS"   Fail  START_TIME is not initialzed! Please call 'Aic Common Setup' firstly.

    ${concated_suite_name}    Replace String    ${SUITE NAME}    ${SPACE}    _
    ${concated_suite_name}    Set Variable    ${concated_suite_name.replace("(", "").replace(")", "").replace("&", "")}

    ${concated_test_name}    Replace String    ${TEST NAME}    ${SPACE}    _
    ${concated_test_name}    Set Variable    ${concated_test_name.replace("[1]", "")}
    ${concated_test_name}    Set Variable    ${concated_test_name.replace("(", "").replace(")", "").replace("&", "")}
    ${timestamp}    Set Variable    ${START_TIME.replace(" ", "_").replace("-", "_").replace(":", "_")}
    #${case_log_path}=    OperatingSystem.Join Path    ${base_folder}   ${concated_suite_name}    ${concated_test_name}   ${timestamp}
    ${case_log_path}=    OperatingSystem.Join Path    ${base_folder}     ${concated_test_name}   ${timestamp}
    [Return]    ${case_log_path}


_Get Remote Log Path
    [Arguments]  ${base_folder}=/tmp/tmp_taic
    ${result}    Run Keyword And Ignore Error    Variable Should Exist    ${TEST NAME}
    ${log_path}    Run Keyword If    "${result[0]}"=="PASS"    _Get Remote Case Log Path   base_folder=${base_folder}
    ...    ELSE    _Get Remote Suite Log Path     base_folder=${base_folder}
    [Return]    ${log_path}


Get RANNIC Interface Name
    [Arguments]    ${vdu_index}=0    ${gnb_index}=0   ${rannic_id}=1
    [Teardown]   Run Keyword And Ignore Error     issh.disconnect  alias=${alias}
    [Documentation]  Get RANNIC Interface Name
    ...    author: tingting.xiao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    07.02.2023, tingting.xiao@nokia-sbell.com, TA case draft
    ...    18.09.2023, chris.l.cao@nokia-sbell.com, move to common KW resource and optimize it
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index    | no | gnb_index, default is 0 |
    ...    | vdu_index    | no | vdu_index, default is 0 |
    ...    | rannic_id   | no | rannic_id, it starts from 1, default is 1 |
    ...
    ...   Example
    ...  | ${rannic_dev_name}   |   Get RANNIC Interface Name |
    ...
    ${conf_dict}      Get vDU One Click Config Dictionary From TestLine   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${slowPathCommonPool}  Set Variable  ${conf_dict["network"]["slowPathCommonPool"]}
    ${tmp}   Split String   ${slowPathCommonPool}   _
    ${slowPathCommonPool_device}   Set Variable  ${tmp[2]}
    Log To Console    slowPathCommonPool_device:${slowPathCommonPool_device}

    ${tmp}   Split String   ${slowPathCommonPool_device}   f
    ${slowPathCommonPool_device_prefix}   Set Variable  ${tmp[0]}
    Log To Console    slowPathCommonPool_device_prefix:${slowPathCommonPool_device_prefix}

    ${alias}   Get Unique Id
    Connect To K8s Master With Tenant Interactively   gnb_index=${gnb_index}   vdu_index=${vdu_index}     alias=${alias}
    ${out_rannic}   issh.Execute
     ...  command=ifconfig |grep ens|grep -v ${slowPathCommonPool_device_prefix}|awk -F: '{print$1}' | awk 'NR==${rannic_id}'    alias=${alias}
    ${rannic_inf}    Strip Prompt      ${out_rannic}
    Log To Console    rannic_id:${rannic_id}, rannic_device:${rannic_inf}

    [Return]    ${rannic_inf}


