*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   cu_log_containerlog.robot



#*** Variables ***



*** Keywords ***
Get Current Host Time By Linux Cmd VCUC
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
    ${ns}  get cu namespace from testline
    ${out}  issh.Execute  command=kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- date +%s
            ...  check_result=False   alias=${alias}

    ${lines}  Get Lines Matching Regexp   ${out}   \\d{5,20}
    [Return]   ${lines}


Get Modified Time By Linux Cmd VCUC
    [Arguments]    ${filename}   ${pod_full_name}   ${container_full_name}  ${alias}=default
    [Documentation]     Get Modified Time By Linux Cmd inside VCU Container
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
    ...    | ${sec} | Get Modified Time By Linux Cmd VCUC | filename=/root/a.txt | container_id=${conainer_id} |
    ${ns}  get cu namespace from testline
    ${sudo_outer}  Get Sudo For VCU K8s Admin Command
    ${out}  issh.Execute
            ...  command=${sudo_outer} kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- stat --format=%Y ${filename}
            ...  check_result=False   alias=${alias}

    ${lines}  Get Lines Matching Regexp   ${out}   \\d{8,20}
    [Return]   ${lines}


Check File Existed In VCUC
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
    ${sudo_outer}  Get Sudo For VCU K8s Admin Command
    ${ns}   get cu namespace from testline
    ${out}  issh.Execute  command=${sudo_outer} kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- ls ${filename}
            ...  check_result=False   alias=${alias}

    ${bExist}   Set Variable If     """No such file or directory""" in """${out}"""     0     1
    Return From Keyword If  ${bExist}==0   0
    ${bExist}   Set Variable If     """syntax error near unexpected token""" in """${out}"""     0     1
    [Return]   ${bExist}


_Remove All Temp File If Needed In VCUC Master Node
    [Arguments]  ${FolderName}    ${alias}=default
    ${out}   issh.Execute  command=ls -F -1 ${FolderName}   alias=${alias}
    ${out}   strip prompt  ${out}
    ${curr_time}    Get Current Host Time By Linux Cmd Interactively  alias=${alias}
    ${lines}   split to lines   ${out}

    #delete Files 2 Hours Ago
    ${threshold}   Set Variable   7200

    FOR   ${file}    IN    @{lines}
        Continue For Loop If   '${file}'==''
        ${fullname}   Join Path   ${FolderName}   ${file}
        #${bExist}   Check File Existed    ${fullname}   alias=${alias}
        ${bExist}     Check File Existed In Linux Server Via Interactive SSH   ${fullname}   alias=${alias}
        Continue For Loop If   ${bExist}==0
        _Remove One Temp File If Needed VCUC Master Node    foldername=${FolderName}   filename=${file}
        ...   curr_time=${curr_time}     thrashold=${threshold}   alias=${alias}
    END


_Remove All Temp File If Needed From VCUC
    [Arguments]  ${FolderName}   ${pod_full_name}   ${container_full_name}  ${ns}  ${alias}
    #${out}  issh.Execute  command=kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- ls -F -1 ${FolderName}
     #       ...  check_result=False   alias=${alias}
    ${sudo_outer}  Get Sudo For VCU K8s Admin Command

    ${out}  issh.Execute  command=${sudo_outer} kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- ls ${FolderName}
            ...  check_result=False   alias=${alias}
    ${out}  strip prompt   ${out}
    ${curr_time}    Get Current Host Time By Linux Cmd VCUC   pod_full_name=${pod_full_name}   container_full_name=${container_full_name}
      ...   alias=${alias}
    ${lines}   split to lines   ${out}

    #${lines}   Split String  ${out}

    #delete Files 60 min ago(3600)
    ${threshold}   Set Variable   3600

    FOR   ${file}    IN    @{lines}
        Continue For Loop If   '${file}'==''
        ${fullname}   Join Path   ${FolderName}   ${file}
        ${bExist}   Check File Existed In VCUC   ${fullname}
            ...  pod_full_name=${pod_full_name}   container_full_name=${container_full_name}   alias=${alias}
        Continue For Loop If   ${bExist}==0
        _Remove One Temp File If Needed VCUC   foldername=${FolderName}   filename=${file}
        ...   curr_time=${curr_time}     thrashold=${threshold}
        ...   pod_full_name=${pod_full_name}   container_full_name=${container_full_name}    alias=${alias}
    END


_Remove One Temp File If Needed VCUC Master Node
    [Arguments]    ${foldername}   ${filename}    ${curr_time}    ${thrashold}   ${alias}=default
    # ${foldername}:  /tmp/tmp_wireshark
    ${fullname}    Join Path    ${foldername}     ${filename}
    ${filemtime}    Get Modified Time By Linux Cmd Interactively  filename=${fullname}   alias=${alias}
    ${delta}    Evaluate   ${curr_time}-${filemtime}
    ${bDeleteIt}    Set Variable If    ${delta}>${thrashold}    1      0
    #${sudo}   Get Sudo   alias=${alias}
    Run Keyword If   ${bDeleteIt}==1   issh.Execute   command=rm -rf ${fullname}    alias=${alias}


_Remove One Temp File If Needed VCUC
    [Arguments]    ${foldername}   ${filename}    ${curr_time}    ${thrashold}  ${pod_full_name}   ${container_full_name}  ${alias}
    # ${foldername}:  /tmp/tmp_wireshark
    ${sudo_outer}  Get Sudo For VCU K8s Admin Command
    ${ns}  get cu namespace from testline

    ${fullname}    Join Path    ${foldername}     ${filename}
    ${filemtime}    Get Modified Time By Linux Cmd VCUC   filename=${fullname}  pod_full_name=${pod_full_name}
     ...   container_full_name=${container_full_name}  alias=${alias}
    ${delta}    Evaluate   ${curr_time}-${filemtime}
    ${bDeleteIt}    Set Variable If    ${delta}>${thrashold}    1      0
    ${out}  Run Keyword If   ${bDeleteIt}==1
      ...   issh.Execute  command=${sudo_outer} kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- rm -rf ${fullname}
      ...  check_result=False   alias=${alias}


Begin K8s Log in CNF CU
    #[Arguments]    ${gnb_index}=0
    [Documentation]    Begin K8s Log in CNF CU
    ...    *AUTHOR* rui.3.li@nokia-sbell.com
    ...    history change, <date>,<who>,<what and how>
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    |  gnb_index        | YES  | default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Handle of 'Begin K8s Log in CNF CU', it will be used in 'End K8s Log'
    ...
    ...    Example
    ...    Capture in one POD and one container
    ...    | ${handle} | Begin K8s Log in CNF CU |
    ...    | sleep  | 30 |
    ...    | ${log_file} | End K8s Log in CNF CU | handle=${handle}  |  pod_name=up | container_name=l2rt |
    ...
    ...    Capture in two POD and two containers
    ...    | ${handle} | Begin K8s Log in CNF CU |
    ...    | sleep  | 30 |
    ...    | ${log_file} | End K8s Log in CNF CU | handle=${handle}  |  pod_name=up | container_name=l2rt |
    ...    | ${log_file2} | End K8s Log in CNF CU | handle=${handle}  |  pod_name=oamcp | container_name=cprt |

    Log To Console    Begin K8s Log in CNF CU
    ${alias}    Connect To CU K8S Master With Admin
    ${date_info}=   issh.execute   command=date --rfc-3339=ns  check_result=${False}   alias=${alias}
    ${datetime}=    get regexp matches    ${date_info}      (\\d+-\\d+-\\d+ \\d+:\\d+:\\d+.\\d+\\+\\S+)    1
    ${k8s_master_datetime}=    set variable   ${datetime[0]}
    ${k8s_master_datetime}=    replace string  ${k8s_master_datetime}  ${SPACE}  T
    [Return]  ${k8s_master_datetime}
    [Teardown]   disconnect interactive connections


End k8s Log in CNF CU
    [Arguments]    ${handle}    ${pod_abbr}    ${container}   ${gnb_index}=0
    [Teardown]     run keyword and ignore error  disconnect interactive connection   alias=${alias}
    [Documentation]    End K8s Log in CNF CU
    ...    *AUTHOR* rui.3.li@nokia-sbell.com
    ...    history change, <date>,<who>,<what and how>
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | handle     |  Yes | it's returned from 'Begin K8s Log in CNF CU' |
    ...    | pod_abbr   |  Yes | pod abbreviation name, eg, oamcp, uprt |
    ...    | container  | Yes | container name, e.g. oam, oamfh, nwmgmt, cprt, rcpsdl, l2rt, l2hi, l1hi |
    ...	   | gnb_index  | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Handle of 'Begin K8s Log in CNF CU', it will be used in 'End K8s Log in CNF CU'
    ...
    ...    Example
    ...    Capture in one POD and one container
    ...    | ${handle} | Begin K8s Log in CNF CU |
    ...    | sleep  | 30 |
    ...    | ${log_file} | End K8s Log in CNF CU | handle=${handle}  |  pod_name=up | container_name=l2rt |
    ...
    ...    Capture in two POD and two containers
    ...    | ${handle} | Begin K8s Log in CNF CU |
    ...    | sleep  | 30 |
    ...    | ${log_file} | End K8s Log in CNF CU | handle=${handle}  |  pod_name=up | container_name=l2rt |
    ...    | ${log_file2} | End K8s Log in CNF CU | handle=${handle}  |  pod_name=oamcp | container_name=cprt |

    Log To Console    End K8s Log in CNF CU
    ${alias}    Connect To CU K8S Master With Admin
    ${full_pod_name}   Get CU Full Pod Name By Pod Abbreviation    pod_abbr=${pod_abbr}   alias=${alias}
        ...  gnb_index=${gnb_index}
    ${full_ctr_name}    Run Keyword If  '${container}'!='all'
    ...   Get CU Full Container Name By Container Abbreviation   ctr_abbr=${container}
    ${remote_file}   Get A Remote File  ${pod_abbr}_${container}.log     alias=${alias}
    ${unique_id}     get unique id   precise=LOW
    ${local_ute_file}   get a file  ${pod_abbr}_${container}_${unique_id}.log
    ${ns}=   set variable  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.namespace}
    ${function_cmd}=   Run Keyword If  '${container}'=='all'
    ...  set variable  kubectl logs ${full_pod_name} --all-containers=true --since-time=${handle} -n ${ns}
    ...  ELSE  set variable  kubectl logs ${full_pod_name} -c ${full_ctr_name} --since-time=${handle} -n ${ns}

    ${cmd}  set variable   nohup ${function_cmd} > ${remote_file} 2>&1 &
    ${out}  issh.Execute  command=${cmd}   alias=${alias}
    ${out}  issh.Execute  command=echo $!   alias=${alias}
    ${out}  strip prompt  ${out}
    ${pid}  parse number only from content  ${out}
    Wait Until Process Disappear   pid=${pid}   alias=${alias}
    ${out}  issh.Execute  command=ps -ef|grep kubectl   alias=${alias}

    ${out}  issh.Execute  command=sync  alias=${alias}
    ${out}  issh.downloadfile   remote_path=${remote_file}   local_path=${local_ute_file}   alias=${alias}
    [Return]  ${local_ute_file}

