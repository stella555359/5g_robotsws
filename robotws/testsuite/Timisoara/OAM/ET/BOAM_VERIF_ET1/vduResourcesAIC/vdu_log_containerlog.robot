*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   vdu_log_containerlog.robot



#*** Variables ***



*** Keywords ***
Get Remote Syslog Server Info
    [Documentation]    get the remote log server info such as server usermane/password
    ...     IP and port, current only one remote log server elastic server in our lab
    ...    So we set the fixed value in this KW, later if it's defined
    ...    in init file then we can update this KW
    ...    *AUTHOR* zhaori.deng@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...    *RETURN VALUE*
    ...    Username, password, IP address and port of elastic server
    ...
    ...    Example
    ...    | ${user} | ${pwd} | ${ip} | ${port} | ${prompt} | Get Remote Syslog Server Info |
    ...
    ${user}   set variable   root
    ${pwd}   set variable   c19liu
    ${IP}   set variable   10.70.34.165
    ${port}   set variable   9200
    ${prompt}   set variable   \\[root@master\\S+\\s\\~\\]\\#
    [Return]    ${user}   ${pwd}   ${IP}   ${port}   ${prompt}


Get Modified Time By Linux Cmd VDUC
    [Arguments]    ${filename}   ${container_id}  ${alias}=default
    [Documentation]     Get Modified Time By Linux Cmd inside VDU Container
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
    ...    | ${sec} | Get Modified Time By Linux Cmd VDUC | filename=/root/a.txt | container_id=${conainer_id} |
    ${out}    tafssh.Execute     command=sudo docker exec -it ${container_id} stat --format=%Y ${filename}    connection=${alias}
    ${lines}  Get Lines Matching Regexp   ${out}   \\d{8,20}
    [Return]   ${lines}


Get Modified Time By Linux Cmd VDUC For OCP
    [Arguments]    ${filename}    ${pod_name}    ${container_name}    ${alias}=default
    [Documentation]     Get Modified Time By Linux Cmd inside VDU Container
    ...    *AUTHOR* mengli.yang@nokia-sbell.com
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
    ...    | ${sec} | Get Modified Time By Linux Cmd VDUC For OCP | filename=/root/a.txt | container_id=${conainer_id} |
    ${out}    issh.Execute     command=kubectl exec -it ${pod_name} -c ${container_name} -n ${ns} -- stat --format=%Y ${filename}
    ...                          alias=${alias}
    ${lines}  Get Lines Matching Regexp   ${out}   \\d{8,20}
    [Return]   ${lines}


Get Current Host Time By Linux Cmd VDUC Interactively
    [Arguments]  ${pod_full_name}  ${container_full_name}  ${alias}=default
    [Documentation]    Get Current Host Time By Linux Cmd
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    No input parameter.
    ...
    ...    *RETURN VALUE*
    ...     time with unit of second.
    ...
    ...    Example
    ...    | ${sec} | Get Current Host Time By Linux Cmd |
    ${ns}  Get vDU Namespace From TestLine
    ${out}  issh.Execute  command=kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- date +%s
            ...  check_result=False   alias=${alias}

    ${lines}  Get Lines Matching Regexp   ${out}   \\d{5,20}
    [Return]   ${lines}

Get Current Host Time By Linux Cmd VDUC For OCP
    [Arguments]  ${pod_name}    ${container_name}    ${alias}=default
    [Documentation]    Get Current Host Time By Linux Cmd For OCP
    ...    *AUTHOR* mengli.yang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    No input parameter.
    ...
    ...    *RETURN VALUE*
    ...     time with unit of second.
    ...
    ...    Example
    ...    | ${sec} | Get Current Host Time By Linux Cmd |
    ${ns}   Get VDU Namespace From TestLine
    ${out}    issh.Execute     command=kubectl exec -it ${pod_name} -c ${container_name} -n ${ns} -- date +%s   alias=${alias}
    ${lines}  Get Lines Matching Regexp   ${out}   \\d{5,20}
    [Return]   ${lines}

Get Current Host Time By Linux Cmd VDUC
    [Arguments]  ${container_id}  ${alias}=default
    [Documentation]    Get Current Host Time By Linux Cmd
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    No input parameter.
    ...
    ...    *RETURN VALUE*
    ...     time with unit of second.
    ...
    ...    Example
    ...    | ${sec} | Get Current Host Time By Linux Cmd |
    ${out}    tafssh.Execute     command=sudo docker exec -it ${container_id} date +%s    connection=${alias}
    ${lines}  Get Lines Matching Regexp   ${out}   \\d{5,20}
    [Return]   ${lines}


Check File Existed In VDUC
    [Arguments]  ${filename}   ${container_id}   ${alias}=default
    [Documentation]   Check File Exist or not inside VDU container
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
    ...    | ${bExit} | Check File Existed In VDUC |  filename=/root/a.txt | container_id=123adadf23 | alias=default |
    ...
    ${out}    tafssh.Execute     command=sudo docker exec -it ${container_id} ls ${filename}    connection=${alias}
    ${bExist}   Set Variable If     """No such file or directory""" in """${out}"""     0     1
    Return From Keyword If  ${bExist}==0   0
    ${bExist}   Set Variable If     """syntax error near unexpected token""" in """${out}"""     0     1
    [Return]   ${bExist}


Check File Existed In VDUC Interactively
    [Arguments]  ${filename}  ${pod_full_name}  ${container_full_name}   ${alias}=default
    [Documentation]   Check File Exist or not inside VCU container
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
    ...    | ${bExit} | Check File Existed In VDUC |  filename=/root/a.txt | container_id=123adadf23 | alias=default |
    ...
    ${sudo_outer}   Get K8s Admin SSH Connection Info
    ${ns}   Get vDU Namespace From TestLine
    ${out}  issh.Execute  command=${sudo_outer} kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- ls ${filename}
            ...  check_result=False   alias=${alias}

    ${bExist}   Set Variable If     """No such file or directory""" in """${out}"""     0     1
    Return From Keyword If  ${bExist}==0   0
    ${bExist}   Set Variable If     """syntax error near unexpected token""" in """${out}"""     0     1
    [Return]   ${bExist}

Check File Existed In VDUC For OCP
    [Arguments]  ${filename}   ${pod_name}   ${container_name}    ${alias}=default
    [Documentation]   Check File Exist or not inside VDU container
    ...    *AUTHOR* mengli.yang@nokia-sbell.com
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
    ...    | ${bExit} | Check File Existed In VDUC |  filename=/root/a.txt | container_id=123adadf23 | alias=default |
    ...
    ${ns}   Get VDU Namespace From TestLine
    ${out}    issh.Execute     command=kubectl exec -it ${pod_name} -c ${container_name} -n ${ns} -- ls ${filename}
    ...                          alias=${alias}
    ${bExist}   Set Variable If     """No such file or directory""" in """${out}"""     0     1
    Return From Keyword If  ${bExist}==0   0
    ${bExist}   Set Variable If     """syntax error near unexpected token""" in """${out}"""     0     1
    [Return]   ${bExist}


_Remove All Temp File If Needed In VDU Master Node
    [Arguments]  ${FolderName}    ${alias}=default
    ${out}    tafssh.Execute       command=ls -F -1 ${FolderName}   connection=${alias}
    ${curr_time}    Get Current Host Time By Linux Cmd   alias=${alias}
    #${lines}   Strip Prompt    content=${out}    return_list=True
    ${lines}   split to lines   ${out}

    #delete Files 2 Hours Ago
    ${threshold}   Set Variable   7200

    FOR   ${file}    IN    @{lines}
        Continue For Loop If   '${file}'==''
        ${fullname}   Join Path   ${FolderName}   ${file}
        ${bExist}   Check File Existed    ${fullname}   alias=${alias}
        Continue For Loop If   ${bExist}==0
        _Remove One Temp File If Needed    foldername=${FolderName}   filename=${file}
        ...   curr_time=${curr_time}     thrashold=${threshold}   alias=${alias}
    END


_Remove All Temp File If Needed From VDUC
    [Arguments]  ${FolderName}    ${container_id}  ${alias}
    ${out}    tafssh.Execute     command=sudo docker exec -it ${container_id} ls -F -1 ${FolderName}    connection=${alias}
    ${curr_time}    Get Current Host Time By Linux Cmd VDUC  container_id=${container_id}  alias=${alias}
    ${lines}   split to lines   ${out}

    #delete Files 2 hour ago
    ${threshold}   Set Variable   7200

    FOR   ${file}    IN    @{lines}
        Continue For Loop If   '${file}'==''
        ${fullname}   Join Path   ${FolderName}   ${file}
        ${bExist}   Check File Existed In VDUC   ${fullname}   container_id=${container_id}   alias=${alias}
        Continue For Loop If   ${bExist}==0
        _Remove One Temp File If Needed VDUC   foldername=${FolderName}   filename=${file}
        ...   curr_time=${curr_time}     thrashold=${threshold}   container_id=${container_id}  alias=${alias}
    END

_Remove All Temp File If Needed From VDUC Interactively
    [Arguments]  ${FolderName}   ${pod_full_name}   ${container_full_name}  ${ns}  ${alias}
    #${out}  issh.Execute  command=kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- ls -F -1 ${FolderName}
     #       ...  check_result=False   alias=${alias}
    ${sudo_outer}  Get Sudo For VDU K8s Admin Command

    ${out}  issh.Execute  command=${sudo_outer} kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- ls ${FolderName}
            ...  check_result=False   alias=${alias}
    ${out}  strip prompt   ${out}

    ${curr_time}   Get Current Host Time By Linux Cmd VDUC Interactively   pod_full_name=${pod_full_name}
      ...  container_full_name=${container_full_name}   alias=${alias}
    ${lines}   Split String   ${out}

    #delete Files 60 min ago (3600s)
    ${threshold}   Set Variable   3600

    FOR   ${file}    IN    @{lines}
        Continue For Loop If   '${file}'==''
        ${fullname}   Join Path   ${FolderName}   ${file}
        ${bExist}   Check File Existed In VDUC Interactively   ${fullname}
            ...  pod_full_name=${pod_full_name}   container_full_name=${container_full_name}   alias=${alias}
        Continue For Loop If   ${bExist}==0
        _Remove One Temp File If Needed VDUC Interactively   foldername=${FolderName}   filename=${file}
        ...   curr_time=${curr_time}     thrashold=${threshold}
        ...   pod_full_name=${pod_full_name}   container_full_name=${container_full_name}    alias=${alias}
    END

_Remove All Temp File If Needed From VDUC For OCP
    [Documentation]    Remove All Temp File If Needed From VDUC For OCP
    ...    *AUTHOR* mengli.yang@nokia-sbell.com
    [Arguments]  ${FolderName}    ${pod_name}    ${container_name}    ${alias}
    ${ns}   Get VDU Namespace From TestLine
    ${out}    issh.Execute     command=kubectl exec -it ${pod_name} -c ${container_name} -n ${ns} -- ls -F -1 ${FolderName}
    ...                          alias=${alias}
    ${curr_time}    Get Current Host Time By Linux Cmd VDUC For OCP    pod_name=${pod_name}
    ...                                                                container_name=${container_name}
    ...                                                                alias=${alias}
    ${lines}   split to lines   ${out}
    #delete Files 16 min ago
    ${threshold}   Set Variable   960

    FOR   ${file}    IN    @{lines}
        Continue For Loop If   '${file}'==''
        ${fullname}   Join Path   ${FolderName}   ${file}
        ${bExist}   Check File Existed In VDUC For OCP   ${fullname}
         ...                                              pod_name=${pod_name}
         ...                                              container_name=${container_name}
         ...                                              alias=${alias}
        Continue For Loop If   ${bExist}==0
        _Remove One Temp File If Needed VDUC For OCP   foldername=${FolderName}   filename=${file}
        ...   curr_time=${curr_time}     thrashold=${threshold}
        ...   pod_name=${pod_name}    container_name=${container_name}  alias=${alias}
    END


_Remove One Temp File If Needed VDUC
    [Arguments]    ${foldername}   ${filename}    ${curr_time}    ${thrashold}   ${container_id}  ${alias}
    # ${foldername}:  /tmp/tmp_wireshark
    ${fullname}    Join Path    ${foldername}     ${filename}
    ${filemtime}    Get Modified Time By Linux Cmd VDUC   filename=${fullname}  container_id=${container_id}  alias=${alias}
    ${delta}    Evaluate   ${curr_time}-${filemtime}
    ${bDeleteIt}    Set Variable If    ${delta}>${thrashold}    1      0
    Run Keyword If   ${bDeleteIt}==1
      ...  tafssh.Execute     command=sudo docker exec -it ${container_id} rm -rf ${fullname}    connection=${alias}


_Remove One Temp File If Needed VDUC Interactively
    [Arguments]    ${foldername}   ${filename}    ${curr_time}    ${thrashold}  ${pod_full_name}   ${container_full_name}  ${alias}
    # ${foldername}:  /tmp/tmp_wireshark
    ${sudo_outer}  Get Sudo For VDU K8s Admin Command
    ${ns}  Get vDU Namespace From TestLine

    ${fullname}    Join Path    ${foldername}     ${filename}
    #${filemtime}    Get Modified Time By Linux Cmd VDUC Interactively   filename=${fullname}  pod_full_name=${pod_full_name}
    # ...   container_full_name=${container_full_name}  alias=${alias}
    ${filemtime}   _Get EPOCH Time From String   ${filename}

    ${delta}    Evaluate   ${curr_time}-${filemtime}
    ${bDeleteIt}    Set Variable If    ${delta}>${thrashold}    1      0
    ${out}  Run Keyword If   ${bDeleteIt}==1
      ...   issh.Execute  command=${sudo_outer} kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- rm -rf ${fullname}
      ...  check_result=False   alias=${alias}

_Remove One Temp File If Needed VDUC For OCP
    [Documentation]      mengli.yang@nokia-sbell.com
    ...         this kw is used to Remove One Temp File If Needed VDUC For OCP
    [Arguments]    ${foldername}   ${filename}    ${curr_time}    ${thrashold}
    ...            ${pod_name}    ${container_name}    ${alias}
    ${ns}   Get VDU Namespace From TestLine
    ${fullname}    Join Path    ${foldername}     ${filename}
    ${filemtime}    Get Modified Time By Linux Cmd VDUC For OCP   filename=${fullname}
    ...                                                           pod_name=${pod_name}
    ...                                                           container_name=${container_name}
    ...                                                           alias=${alias}
    ${delta}    Evaluate   ${curr_time}-${filemtime}
    ${bDeleteIt}    Set Variable If    ${delta}>${thrashold}    1      0
    Run Keyword If   ${bDeleteIt}==1
      ...  issh.Execute     command=kubectl exec -it ${pod_name} -c ${container_name} -n ${ns} -- rm -rf ${fullname}
      ...                     alias=${alias}


Collect VDU Describe PODs Log
    [Arguments]  ${vdu_index}=0   ${gnb_index}=0
    [Tags]    CLOUD_PLATFORM_SPECFIC
    [Teardown]  run keyword and ignore error   disconnect interactive connection  alias=${alias}
    [Documentation]   Collect VDU Describe PODs Log
    ...    author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | vdu_index | no | vdu_index, default value is 0 |
    ...    | gnb_index | no | gnb_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Collect VDU Describe PODs Log |
    ...
    ${root_folder}   set variable   describe_vdu_pod
    ${alias}  get unique id
    Connect To K8s Master Interactively   vdu_index=${vdu_index}   gnb_index=${gnb_index}  alias=${alias}
    ${ns_tenant}  Get vDU Namespace From TestLine   vdu_index=${vdu_index}   gnb_index=${gnb_index}
    ${command1}  Create Dictionary   root_folder=${root_folder}  command=describe    resource=pod    option=${EMPTY}   ns=${ns_tenant}
    ${command2}  Create Dictionary   root_folder=${root_folder}  command=get    resource=pod    option=wide   ns=${ns_tenant}
    ${command3}  Create Dictionary   root_folder=${root_folder}  command=get    resource=pod    option=yaml   ns=${ns_tenant}
    ${command4}  Create Dictionary   root_folder=${root_folder}  command=get    resource=pod    option=wide   ns=kube-system
    ${command5}  Create Dictionary   root_folder=${root_folder}  command=get    resource=pod    option=yaml   ns=kube-system
    ${command6}  Create Dictionary   root_folder=${root_folder}  command=get    resource=ep     option=wide   ns=${ns_tenant}
    ${command7}  Create Dictionary   root_folder=${root_folder}  command=get    resource=ep     option=yaml   ns=${ns_tenant}
    ${commands_dict}   Create Dictionary   command1=${command1}   command2=${command2}    command3=${command3}   command4=${command4}
    ...   command5=${command5}   command6=${command6}    command7=${command7}
    ${keys}  Evaluate   list(${commands_dict})
    FOR   ${one_key}   IN   @{keys}
       ${one_command_dict}   Get From Dictionary   ${commands_dict}   ${one_key}
       ${root_folder}  Set Variable  ${one_command_dict["root_folder"]}
       ${command}      Set Variable     ${one_command_dict["command"]}
       ${resource}     Set Variable     ${one_command_dict["resource"]}
       ${option}       Set Variable     ${one_command_dict["option"]}
       ${ns}           Set Variable     ${one_command_dict["ns"]}
      Collect VDU Describe PODs Log With Special Command   alias=${alias}   command=${command}  resource=${resource}   option=${option}
    ...   ns=${ns}   vdu_index=${vdu_index}   gnb_index=${gnb_index}
    END

Collect VDU Describe PODs Log With Special Command
    [Arguments]  ${alias}  ${root_folder}=describe_vdu_pod  ${command}=describe  ${resource}=pod  ${option}=${EMPTY}  ${ns}=cran1
       ...   ${vdu_index}=0   ${gnb_index}=0
    [Tags]    CLOUD_PLATFORM_SPECFIC
    [Documentation]   Collect VDU Describe PODs Log With Special Command
    ...    author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | vdu_index | no | vdu_index, default value is 0 |
    ...    | gnb_index | no | gnb_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Collect VDU Describe PODs Log |
    ...
    #${root_folder}   set variable   describe_vdu_pod
    ${remote_file}  get a remote file   describe_vdu_pod.txt   alias=${alias}
    ${full_command}   Set Variable If  "${option}"=="${EMPTY}"  kubectl ${command} ${resource} -n ${ns} > ${remote_file}
    ...    kubectl ${command} ${resource} -o ${option} -n ${ns} > ${remote_file}
    ${out}  issh.Execute   command=${full_command}   alias=${alias}
    ${out}  issh.Execute   command=sync  alias=${alias}
    ${tmp_id}   get unique id  precise=FORMAT_DATETIME
    #${option_str}  Set Variable  ${option.replace(" ","_")}
    ${local_file_name}   Set Variable If   "${option}"=="${EMPTY}"    kubectl_${command}_${resource}_${ns}_${gnb_index}_${vdu_index}_${tmp_id}.txt
    ...   kubectl_${command}_${resource}_o_${option}_${ns}_${gnb_index}_${vdu_index}_${tmp_id}.txt
    ${local_ute_file_name}  get a file   ${root_folder}   ${local_file_name}
    ${out}  issh.downloadfile   remote_path=${remote_file}   local_path=${local_ute_file_name}   alias=${alias}

Collect VDU Infrastructure Log
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Tags]  CLOUD_PLATFORM_SPECFIC
    [Documentation]   Collect VDU Infrastructure Log
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    23.11.2021,chris.l.cao@nokia-sbell.com, add change history, remove NCS branch to shorten dryrun time
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb_index, default is 0 |
    ...    | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | Collect VDU Infrastructure Log |
    ...
    log to console   Collect VDU Infrastructure Log(gnb_index:${gnb_index},vdu_index:${vdu_index})
    ${platform}   Get Platform Name

#    runkeyword if   "${platform}"=="NCS"   _Collect VDU Infrastructure Log For NCS  gnb_index=${gnb_index}  vdu_index=${vdu_index}
#    ...   ELSE
#        ...   _Collect VDU Infrastructure Log For OCP   gnb_index=${gnb_index}  vdu_index=${vdu_index}
    runkeyword if   "${platform}"=="OCP"   _Collect VDU Infrastructure Log For OCP   gnb_index=${gnb_index}  vdu_index=${vdu_index}



_Collect VDU Infrastructure Log For NCS
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Teardown]   run keyword and ignore error  disconnect interactive connection   alias=${alias}
    [Documentation]   _Collect VDU Infrastructure Log For NCS
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb_index, default is 0 |
    ...    | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | _Collect VDU Infrastructure Log For NCS |
    ...
    log to console   Collect VDU Infrastructure Log(gnb_index:${gnb_index},vdu_index:${vdu_index})
    ${ns}  set variable  kube-system
    ${log_root_folder}   set variable   vdu_infrastructure_log

    ${alias}   Get Unique Id
    connect to k8s master interactively   alias=${alias}

    #kube dns
    ${remote_file}   get a remote file  ${log_root_folder}   kube_dns.log    alias=${alias}
    ${out}   issh.Execute   command=kubectl get pod -n ${ns}|egrep "coredns"|awk '{print $1}'  check_result=${False}  alias=${alias}
    ${dns_pod}   strip prompt  ${out}
    ${out}  issh.Execute  command=kubectl logs ${dns_pod} -c coredns -n ${ns}>${remote_file}   alias=${alias}

    ${out}  strip prompt  ${out}
    ${pid}  parse number only from content  ${out}
    Wait Until Process Disappear   pid=${pid}   alias=${alias}

    ${out}  issh.Execute  command=sync  alias=${alias}
    ${tmp_id}   get unique id   precise=FORMAT_DATETIME
    ${local_file}   get a file   ${log_root_folder}   kube_dns_container_log_${gnb_index}_${vdu_index}_${tmp_id}.log
    ${out}  issh.downloadfile   remote_path=${remote_file}   local_path=${local_file}   alias=${alias}

    #desribe kube-dns pod
    ${remote_file}  get a remote file   ${log_root_folder}   kubesystem_kubedns.txt   alias=${alias}
    ${out}  issh.Execute   command=kubectl describe pod ${dns_pod} -n ${ns} > ${remote_file}    alias=${alias}
    ${out}  issh.Execute   command=sync  alias=${alias}

    ${tmp_id}   get unique id  precise=FORMAT_DATETIME
    ${local_file}  get a file   ${log_root_folder}   kube_dns_describe_pod_${gnb_index}_${vdu_index}_${tmp_id}.txt
    ${out}  issh.downloadfile   remote_path=${remote_file}   local_path=${local_file}   alias=${alias}

    #check dns in container
    ${out}  Kubectl Exec Interactively  container=oam  command=ping oam-asm -c 3   check_result=False  alias=${alias}
    ${out}  Kubectl Exec Interactively  container=oam  command=cat /etc/resolv.conf  check_result=False   alias=${alias}


_Collect VDU Infrastructure Log For OCP
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Teardown]   run keyword and ignore error  disconnect interactive connection   alias=${alias}
    [Documentation]   _Collect VDU Infrastructure Log For OCP
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb_index, default is 0 |
    ...    | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | _Collect VDU Infrastructure Log For OCP |
    ...
    ${alias}   Get Unique Id
    connect to k8s master interactively    gnb_index=${gnb_index}   vdu_index=${vdu_index}  alias=${alias}
    ${out}   issh.Execute   command=kubectl get ns|grep dns|awk '{print $1}'|grep -v NAME  check_result=${False}  alias=${alias}
    ${out}   strip prompt  ${out}
    ${log_root_folder}  set variable  vdu_infrastructure_log
    ${dns_related_namespace}  Split To Lines   ${out}

    FOR  ${ns}  IN   @{dns_related_namespace}
       Collect K8s Kubectl Log For One Namespace   ns=${ns}  gnb_index=${gnb_index}   vdu_index=${vdu_index}  alias=${alias}
        ...  log_root_folder=${log_root_folder}
    END


Collect K8s Kubectl Log For One Namespace
    [Arguments]   ${ns}    ${alias}   ${gnb_index}=0   ${vdu_index}=0   ${log_root_folder}=Collect_VDU_Infrastructure_Log
    [Documentation]   Collect K8s Kubectl Log For One Namespace
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | ns  | yes | namespace,  |
    ...    | alias | yes | alias,  |
    ...    | log_root_folder | no | log_root_folder, default is vdu_infrastructure_log |
    ...    | gnb_index | no | gnb_index, default is 0 |
    ...    | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | ${alias}   Get Unique Id |
    ...    | Connect To K8s Master Interactively | alias=${alias} |
    ...    | Collect K8s Kubectl Log For One Namespace | ns=openshift-dns | alias=myalias |
    ...    | Disconnect Interactive Connection  | alias=${alias} |
    ...
    ${out}   issh.Execute   command=kubectl get pod -n ${ns}|awk '{print $1}'|grep -v NAME  check_result=${False}  alias=${alias}
    ${out}   strip prompt  ${out}
    ${dns_pod_list}  Split To Lines   ${out}
    FOR  ${pod}   IN   @{dns_pod_list}
       log to console    ${pod}
       Collect K8s Kubectl Log For One Pod   ns=${ns}   pod=${pod}   alias=${alias}  log_root_folder=${log_root_folder}
        ...  gnb_index=${gnb_index}   vdu_index=${vdu_index}
    END


Collect K8s Kubectl Log For One Pod
    [Arguments]  ${ns}   ${pod}   ${alias}   ${log_root_folder}=vdu_infrastructure_log   ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   Collect K8s Kubectl Log For One Pod
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | ns  | yes | namespace,  |
    ...    | pod | yes | full pod name,  |
    ...    | alias | yes | alias,  |
    ...    | log_root_folder | no | log_root_folder, default is vdu_infrastructure_log |
    ...    | gnb_index | no | gnb_index, default is 0 |
    ...    | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | ${alias}   Get Unique Id |
    ...    | Connect To K8s Master Interactively | alias=${alias} |
    ...    | Collect K8s Kubectl Log For One Pod | ns=openshift-dns | pod=dns-default-557ms | alias=${alias} |
    ...    | Disconnect Interactive Connection  | alias=${alias} |
    ...
    ${remote_file}   get a remote file  ${log_root_folder}  ${ns}  ${pod}_kubectl_logs.log    alias=${alias}
    ${out}  issh.Execute  command=kubectl logs ${pod} --all-containers=true -n ${ns}>${remote_file}   alias=${alias}
    ${out}  issh.Execute  command=sync  alias=${alias}
    ${tmp_id}   get unique id   precise=FORMAT_DATETIME
    ${local_file}   get a file   ${log_root_folder}   ${ns}   ${pod}_${gnb_index}_${vdu_index}_${tmp_id}.log
    ${out}  issh.downloadfile   remote_path=${remote_file}   local_path=${local_file}   alias=${alias}

    ${remote_file}  get a remote file   ${log_root_folder}   ${ns}  ${pod}_kubectl_describe_pod.txt     alias=${alias}
    ${out}  issh.Execute   command=kubectl describe pod ${pod} -n ${ns} > ${remote_file}    alias=${alias}
    ${out}  issh.Execute   command=sync  alias=${alias}

    ${tmp_id}   get unique id  precise=FORMAT_DATETIME
    ${local_file}  get a file   ${log_root_folder}  ${ns}  ${pod}_kubectl_describe_pod_${gnb_index}_${vdu_index}_${tmp_id}.txt
    ${out}  issh.downloadfile   remote_path=${remote_file}   local_path=${local_file}   alias=${alias}



Begin K8s Log
    [Arguments]     ${gnb_index}=0  ${vdu_index}=0
    [Documentation]    Begin K8s Log
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change, <date>,<who>,<what and how>
    ...    13.9.2021, chris.l.cao@nokia-sbell.com, suppot non-CST timezone
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    Handle of 'Begin K8s Log', it will be used in 'End K8s Log'
    ...
    ...    Example
    ...    Capture in one POD and one container
    ...    | ${handle} | Begin K8s Log |
    ...    | sleep  | 30 |
    ...    | ${log_file} | End K8s Log | handle=${handle}  |  pod_name=up | container_name=l2rt |
    ...
    ...    Capture in two POD and two containers
    ...    | ${handle} | Begin K8s Log |
    ...    | sleep  | 30 |
    ...    | ${log_file} | End K8s Log | handle=${handle}  |  pod_name=up | container_name=l2rt |
    ...    | ${log_file2} | End K8s Log | handle=${handle}  |  pod_name=oamcp | container_name=cprt |
    ...
    ${alias}=  get unique id
    Connect To K8s Master Interactively   alias=${alias}  vdu_index=${vdu_index}  gnb_index=${gnb_index}
    ${date_info}=   issh.execute   command=date --rfc-3339=ns  check_result=${False}   alias=${alias}
    #${datetime}=    get regexp matches    ${date_info}      (\\d+-\\d+-\\d+ \\d+:\\d+:\\d+.\\d+\\+08:00)    1
    ${datetime}=    get regexp matches    ${date_info}      (\\d+-\\d+-\\d+ \\d+:\\d+:\\d+.\\d+\\+\\S+)    1
    ${k8s_master_datetime}=    set variable   ${datetime[0]}
    ${k8s_master_datetime}=    replace string  ${k8s_master_datetime}  ${SPACE}  T
    [Return]  ${k8s_master_datetime}
    [Teardown]   disconnect interactive connection   alias=${alias}


End K8s Log
    [Arguments]   ${handle}  ${pod_abbr}  ${container}   ${gnb_index}=0  ${vdu_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection   alias=${alias}
    [Documentation]    End K8s Log
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change, <date>,<who>,<what and how>
    ...    13.09.2021, chris.l.cao@nokia-sbell.com, change login account from tenant to admin to better support in OCP
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | since_time |  Yes | it's returned from 'Begin K8s Log' |
    ...    | pod_abbr   |  Yes | pod abbreviation name, eg, oamcp, uprt |
    ...    | container  | Yes | container name, e.g. oam, oamfh, nwmgmt, cprt, rcpsdl, l2rt, l2hi, l1hi |
    ...	   | gnb_index  | no | gnb_index, default is 0 |
    ...	   | vdu_index  | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Handle of 'Begin K8s Log', it will be used in 'End K8s Log'
    ...
    ...    Example
    ...    Capture in one POD and one container
    ...    | ${handle} | Begin K8s Log |
    ...    | sleep  | 30 |
    ...    | ${log_file} | End K8s Log | handle=${handle}  |  pod_name=up | container_name=l2rt |
    ...
    ...    Capture in two POD and two containers
    ...    | ${handle} | Begin K8s Log |
    ...    | sleep  | 30 |
    ...    | ${log_file} | End K8s Log | handle=${handle}  |  pod_name=up | container_name=l2rt |
    ...    | ${log_file2} | End K8s Log | handle=${handle}  |  pod_name=oamcp | container_name=cprt |
    ...
    ${alias}   get unique id
    Connect To K8s Master Interactively    vdu_index=${vdu_index}   alias=${alias}   gnb_index=${gnb_index}
    ${full_pod_name}   Get Full Pod Name By Pod Abbreviation Interactively    pod_abbr=${pod_abbr}   alias=${alias}
        ...  gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${full_ctr_name}    Run Keyword If  '${container}'!='all'
        ...   Get Full Container Name By Container Abbreviation   ctr_abbr=${container}   gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${remote_file}   get a remote file  ${pod_abbr}_${container}.log     alias=${alias}
    ${unique_id}     get unique id   precise=LOW
    ${local_ute_file}   get a file  ${pod_abbr}_${container}_${unique_id}.log
    ${ns}   Get vDU Namespace From TestLine   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${function_cmd}=   Run Keyword If  '${container}'=='all'
    ...  set variable  kubectl logs ${full_pod_name} --all-containers=true --since-time=${handle} -n ${ns}
    ...  ELSE  set variable  kubectl logs ${full_pod_name} -c ${full_ctr_name} --since-time=${handle} -n ${ns}
#    ${cmd}  set variable   nohup ${function_cmd} > ${remote_file} 2>&1 &
#
#    ${out}  issh.Execute  command=${cmd}   alias=${alias}
#    ${out}  issh.Execute  command=echo $!   alias=${alias}
#    ${out}  strip prompt  ${out}
#    ${pid}  parse number only from content  ${out}
#    Wait Until Process Disappear   pid=${pid}   alias=${alias}
#    ${out}  issh.Execute  command=ps -ef|grep kubectl   alias=${alias}
    ${old_timeout}    issh.set_timeout  600   alias=${alias}
    ${cmd}  set variable   ${function_cmd} > ${remote_file}
    ${out}  issh.Execute  command=${cmd}   alias=${alias}
    issh.set_timeout  ${old_timeout}   alias=${alias}
    ${out}  issh.Execute  command=sync  alias=${alias}
    ${out}  issh.downloadfile   remote_path=${remote_file}   local_path=${local_ute_file}   alias=${alias}
    [Return]  ${local_ute_file}