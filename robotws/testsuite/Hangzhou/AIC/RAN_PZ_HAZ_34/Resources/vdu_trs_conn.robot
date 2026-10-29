*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   vdu_trs_conn.robot
...   vdu connection related KW.




*** Variables ***



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


Get Container ID
    [Arguments]    ${ctr_abbr}   ${alias}=default   ${gnb_index}=0   ${vdu_index}=0
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
    ${full_container_name}     Get Full Container Name By Container Abbreviation  ctr_abbr=${ctr_abbr}
    ...    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${ssh_command}   Set Variable   sudo crictl ps|grep "${full_container_name} "|awk '{print $1}'
    ${out}  issh.Execute  command=${ssh_command}  alias=${alias}
    ${out}  Strip Prompt  ${out}

    ${container_id}   Set Variable  ${out.strip()}
    [Return]  ${container_id}


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


Get PID For Container
    [Arguments]    ${ctr_abbr}   ${alias}=default   ${gnb_index}=0   ${vdu_index}=0
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
    ${container_id}   Get Container ID   ctr_abbr=${ctr_abbr}  alias=${alias}   gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${ssh_command}   Set Variable   sudo crictl inspect --output yaml ${container_id}| grep 'pid:'|awk -F ':' '{print $2}'
    ${out}  issh.Execute  command=${ssh_command}  alias=${alias}
    ${out}  Strip Prompt  ${out}

    ${pid}   Set Variable  ${out.strip()}
    [Return]  ${pid}


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


Docker Exec By Container ID Interactively
    [Arguments]  ${container_id}   ${command}   ${alias}=default   ${bWriteBare}=${False}   ${check_result}=${True}
    [Documentation]    Docker Exec By Container ID Interactively
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | container_id | Yes | container id, e.g, 0c0a2ea28714 |
    ...    | command  | yes | command, e.g, hostname, ifconfig f12 |
    ...    | alias    | no | alias, default value is default |
    ...    | bWriteBare  | no | if ${True}, write command and return without match the prompt |
    ...    |             |   | if ${False}, write command and return with the condition of matching the prompt, default value is ${False} |

    ...
    ...    *RETURN VALUE*
    ...    Linux command execution result inside container.
    ...
    ...    Example
    ...    | ${out}      | Docker Exec By Container ID Interactively |  container_id=0c0a2ea28714 | command=ifconfig oam3 | alias=${alias} |
    ...
    ${sudo}   Get Sudo Via Interactive SSH   alias=${alias}
    ${out}   Run Keyword If   "${bWriteBare}"=="${True}"
      ...    _Docker Exec By Container ID Interactively Write Bare  container_id=${container_id}  command=${command}  alias=${alias}
    ...   ELSE
      ...    issh.Execute  command=${sudo} docker exec -it ${container_id} ${command}   check_result=${check_result}  alias=${alias}
    [Return]  ${out}


_Docker Exec By Container ID Interactively Write Bare
    [Arguments]  ${container_id}   ${command}   ${alias}=default
    #${sudo}   Get Sudo Via Interactive SSH   alias=${alias}
    ${sudo}   Get Sudo For VDU Node for Linux Command According To Current User Interactively  alias=${alias}
    issh.Execute Bare  command=${sudo} docker exec -it ${container_id} ${command}   alias=${alias}
    ${out}   Send ENTER Interactively   alias=${alias}
    [Return]  ${out}


Get Host Name
    [Arguments]  ${alias}=default
    ${out}   issh.Execute   command=hostname   alias=${alias}
    ${lines}  Split To Lines  ${out}
    ${hostname}   Set Variable   ${lines[1].strip()}
    [Return]  ${hostname}


Disconnect All SSH Connections
    Run Keyword And Ignore Error   Disconnect Interactive Connections
    Run Keyword And Ignore Error   tafssh.Reset Cache




Get Sudo For VDU Node for Linux Command According To Current User Interactively
    [Arguments]  ${alias}=default
    [Documentation]  Get Sudo For VDU Node for Linux Command According To Current User Interactively
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | connection       |  no | connection, defaut is default |
    ...
    ...    *RETURN VALUE*
    ...    sudo or ${EMPTY}
    ...
    ...    Example
    ...    | ${sudo} | Get Sudo For VDU Node for Linux Command According To Current User |
    ...
    ${current_user_name}  Get Current User Name Interactively  alias=${alias}
    ${sudo}  set variable if   "${current_user_name}"=="root"   ${EMPTY}
    ...   "${current_user_name}"=="cbis-admin"   sudo    ${EMPTY}
    [Return]  ${sudo}


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
    ${prompt_oe_server_NCS}  set variable   \\[cloudadmin@\\S+\\s\\S+\\]\\$|\\[root@\\S+\\s\\S+\\s+\\S+\\]\\#|\\[root@\\S+\\s\\S+\\]\\#
    ${prompt_oe_server_NCS}  set variable   ${prompt_oe_server_NCS}|\\[cbis-admin@\\S+\\s\\S+\\s+\\S+\\]\\$
    ${prompt_oe_server_NCS}  set variable   ${prompt_oe_server_NCS}|\\[cbis-admin@\\S+\\s\\S+\\]\\$
    ${prompt_oe_server_NCS}  set variable   ${prompt_oe_server_NCS}|\\[cranuser\\d+@\\S+\\s\\S+\\s+\\S+\\]\\$
    ${prompt_oe_server_NCS}  set variable   ${prompt_oe_server_NCS}|\\[cranuser\\d+@\\S+\\s\\S+\\]\\$

    ${prompt_oe_server_OCP}  set variable   \\[core@\\S+\\s\\S+\\]\\$
    ${prompt_oe_server_NCS}  set variable   ${prompt_oe_server_NCS}|${prompt_oe_server_OCP}

    ${out}   issh.Execute   command=hostname  alias=${alias}
    ${matches}   get regexp matches  ${out}   \\[root@controller\\(FHGW.*\\).*\\]
    return from keyword if  ${matches}   FHGW

    ${matches}   get regexp matches  ${out}   \\[cloudadmin@controller-\\d.*\\]|\\[cranuser\\d+@controller-\\d.*\\]
    return from keyword if  ${matches}   OE_SERVER_CONTROLLER

    #NCS:  [root@hz25ah0533r-ah05-3-3r-singlenodecluster-0 ~ ]#    , [cbis-admin@ncs-chris-ac06-1-1l-allinone-0 ~ (Master)]$
    #${matches}   get regexp matches  ${out}
    #  ...   \\[root@\\S+\\s\\S+\\]|\\[cbis-admin@\\S+\\s\\S+\\s\\S+\\]|\\[cranuser\\d+@\\S+\\s\\S+\\]|\\[cranuser\\d+@\\S+\\s\\S+\\s\\S+\\]
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
