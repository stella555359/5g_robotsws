*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   vdu_log_containerlog.robot



*** Variables ***
${ns}    cran1


*** Keywords ***
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
    Log    ${pod_full_name}
    Log    ${container_full_name}
    ${out}  issh.Execute  command=ls ${filename}   check_result=${False}   alias=${alias}

    ${bExist}   Set Variable If     """No such file or directory""" in """${out}"""     0     1
    Return From Keyword If  ${bExist}==0   0
    ${bExist}   Set Variable If     """syntax error near unexpected token""" in """${out}"""     0     1
    [Return]   ${bExist}

_Remove All Temp File If Needed From VDUC Interactively
    [Arguments]  ${FolderName}   ${pod_full_name}   ${container_full_name}  ${ns}  ${alias}
    Log    ${ns}
    ${out}  issh.Execute  command=ls ${FolderName}   check_result=${False}   alias=${alias}
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

_Remove One Temp File If Needed VDUC Interactively
    [Arguments]    ${foldername}   ${filename}    ${curr_time}    ${thrashold}  ${pod_full_name}   ${container_full_name}  ${alias}
    # ${foldername}:  /tmp/tmp_wireshark
    ${fullname}    Join Path    ${foldername}     ${filename}
    ${filemtime}   _Get EPOCH Time From String   ${filename}

    ${delta}    Evaluate   ${curr_time}-${filemtime}
    ${bDeleteIt}    Set Variable If    ${delta}>${thrashold}    1      0
    ${out}  Run Keyword If   ${bDeleteIt}==1   issh.Execute  command=rm -rf ${fullname}  check_result=${False}   alias=${alias}
    Log    ${pod_full_name}
    Log    ${container_full_name}

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
    Connect To K8s Master With Tenant Interactively   vdu_index=${vdu_index}   gnb_index=${gnb_index}  alias=${alias}
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


Collect VDU Journal Log
    [Arguments]  ${collect_start_time}=${EMPTY}   ${vdu_index}=0   ${gnb_index}=0
    [Teardown]  run keyword and ignore error   disconnect interactive connection  alias=${alias}
    [Documentation]   Collect VDU Journal Log
    ...    author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | collect_start_time | no | collect start time, like '2023-03-13 21:41:55', default value is ${EMPTY} |
    ...    |                    |    | ${EMPTY} means not to collect journal log |
    ...    | vdu_index | no | vdu_index, default value is 0 |
    ...    | gnb_index | no | gnb_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Collect VDU Journal Log | collect_start_time=2023-03-13 21:41:55 |
    ...
    Return From Keyword If  "${collect_start_time}"=="${EMPTY}"

    ${alias}  Get Unique Id
    Connect To K8s Master Interactively   vdu_index=${vdu_index}   gnb_index=${gnb_index}  alias=${alias}
    ${end_time}    Get time    exclude_millis=yes
    ${delta}  DateTime.Subtract Date From Date  ${end_time}  ${collect_start_time}   exclude_millis=true
    ${out}   issh.Execute   command=date +%s    alias=${alias}
    ${out}   Strip Prompt  ${out}
    ${start_time_in_vdu_number}  Evaluate  int(${out})-int(${delta})
    ${out}   issh.Execute   command=date "+%Y-%m-%d %H:%M:%S" -d @${start_time_in_vdu_number}    alias=${alias}
    ${start_time_in_vdu}   Strip Prompt  ${out}
    ${log_file_name}  Get Unique Id  precise=FORMAT_DATETIME  suffix=.log
    ${remote_filename}  Get A Remote File  journal_log_vdu  ${log_file_name}  alias=${alias}
    ${out}  issh.Execute  command=journalctl --since="${start_time_in_vdu}" --no-page> ${remote_filename}
    ...  alias=${alias}
    ${local_ute_file_name}  Get A File   journal_log_vdu   ${log_file_name}
    ${out}  issh.downloadfile   remote_path=${remote_filename}   local_path=${local_ute_file_name}   alias=${alias}


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

    runkeyword if   "${platform}"=="OCP"   _Collect VDU Infrastructure Log For OCP   gnb_index=${gnb_index}  vdu_index=${vdu_index}


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
    [Arguments]   ${handle}  ${pod_abbr}=${EMPTY}  ${container}=${EMPTY}   ${gnb_index}=0  ${vdu_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection   alias=${alias}
    [Documentation]    End K8s Log
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change, <date>,<who>,<what and how>
    ...    13.09.2021, chris.l.cao@nokia-sbell.com, change login account from tenant to admin to better support in OCP
    ...    10.05.2023, chris.l.cao@nokia-sbell.com, support container abbreviation without pod_abbr value
    ...    26.10.2023, chris.l.cao@nokia-sbell.com, retry 120s, add '_VDU Get Pod Status' to check pod status
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | since_time | Yes | it's returned from 'Begin K8s Log' |
    ...    | pod_abbr   | No | pod abbreviation name, eg, oamext, l2rt |
    ...    | container  | No | container name, e.g. oam, oamfh, nwmgmt, cprt, rcpsdl, l2rt, l2hi, l1hi |
    ...	   | gnb_index  | no | gnb_index, default is 0 |
    ...	   | vdu_index  | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    File name where k8s log was placed.
    ...
    ...    Example
    ...    Capture in one POD and one container
    ...    | ${handle} | Begin K8s Log |
    ...    | sleep  | 30 |
    ...    | ${log_file} | End K8s Log | handle=${handle}  | container=l2rt |
    ...
    ...    Capture in two POD and two containers
    ...    | ${handle} | Begin K8s Log |
    ...    | sleep  | 30 |
    ...    | ${log_file} | End K8s Log | handle=${handle}  | container=l2rt |
    ...    | ${log_file2} | End K8s Log | handle=${handle} | container=oamagent |
    ...
    Run Keyword If   "${pod_abbr}"=="${EMPTY}" and '${container}'=='all'  Fail  Need give pod_abbr for collecting all containers log!

    ${pod_abbr}   Run Keyword If   "${pod_abbr}"=="${EMPTY}"   Get Pod Abbreviation By Container Abbreviation   container_abbr=${container}
    ...   ELSE  Set Variable  ${pod_abbr}
    ${container_prefix}   Run Keyword If  "${container}"=="nwmgmt"   Get Container Name Prefix  vdu_index=${vdu_index}

    ${alias}   get unique id
    Connect To K8s Master Interactively    vdu_index=${vdu_index}   alias=${alias}   gnb_index=${gnb_index}
    ${full_pod_name}   Get Full Pod Name By Pod Abbreviation Interactively    pod_abbr=${pod_abbr}   alias=${alias}
        ...  gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${full_pod_name}    Set Variable    ${full_pod_name.replace("\x1b[?2004l\r","")}
    ${full_ctr_name}    Run Keyword If  '${container}'=='nwmgmt'   Set Variable   ${container_prefix}${container}
        ...   ELSE IF   '${container}'!='all'   Get Full Container Name By Container Abbreviation
                        ...    ctr_abbr=${container}   gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${unique_id}     get unique id   precise=LOW
    ${remote_file}   get a remote file  ${full_pod_name}_${unique_id}.log     alias=${alias}
    ${local_ute_file}   get a file  ${full_pod_name}_${unique_id}.log

#    ${ns}   Get vDU Namespace From TestLine   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${function_cmd}=   Run Keyword If  '${container}'=='all'
    ...  set variable  kubectl logs ${full_pod_name} --all-containers=true --since-time=${handle} -n ${ns}
    ...  ELSE  set variable  kubectl logs ${full_pod_name} -c ${full_ctr_name} --since-time=${handle} -n ${ns}
    ${old_timeout}    issh.set_timeout  600   alias=${alias}
    ${cmd}  set variable   ${function_cmd} > ${remote_file}

    _VDU Get Pod Status    gnb_index=${gnb_index}   vdu_index=${vdu_index}
    FOR   ${i}   IN RANGE   13
        ${out}  issh.Execute  command=${cmd}   alias=${alias}
        ${out}  issh.Execute  command=wc -c ${remote_file}|awk '{print $1}'   alias=${alias}
        ${out}    Set Variable    ${out.replace("\x1b[?2004l\r","")}
        ${file_size}  Strip Prompt   ${out}
        Exit For Loop If   ${file_size} > 0
        _VDU Get Pod Status    gnb_index=${gnb_index}   vdu_index=${vdu_index}
        Sleep  10
    END

    issh.set_timeout  ${old_timeout}   alias=${alias}
    ${out}  issh.Execute  command=sync  alias=${alias}
    ${out}  issh.downloadfile   remote_path=${remote_file}   local_path=${local_ute_file}   alias=${alias}
    [Return]  ${local_ute_file}


VNF Reset Should Be Expected
    [Arguments]  ${healing_log}   ${operator}=ge   ${number}=1
    [Documentation]  VNF Reset Should Be Expected, it support both VDU and VCU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    *Change History*
    ...    | 2023-10-31 | chris.l.cao@nokia-sbell.com | new KW |
    ...
    ...    *Arguments Description*
    ...    | Input Parameters | Man. | Description |
    ...    | healing_log | Yes  | healing_log, .e.g /tmp/healing_controller.log |
    ...    | operator | No  | operator, it can be eq/gt/ge/lt/le/ne. The meaning is eq:==, gt:>, ge:>=, lt:<, le:<=, ne:!= , default is eq |
    ...    | number | No  | reset times number, default is 1 |
    ...
    ...    *RETURN VALUE*
    ...    VNF restarting number
    ...
    ...    Example
    ...    | ${handle} | Begin K8s Log |
    ...    | execute some steps here |
    ...    | ${local_auto_healing_log} | End K8s Log |  handle=${handle} | pod_abbr=healing-controller  |  container=healing-controller |
    ...    | VNF Reset Should Be Expected | healing_log=${local_auto_healing_log} |
    ...    | VNF Reset Should Be Expected | healing_log=${local_auto_healing_log} | operator=gt | number=2 |
    ...
    ...    Check there is no VNF reset
    ...    | VNF Reset Should Be Expected | healing_log=${local_auto_healing_log} | operator=eq | number=0 |
    ...
    ${operator}   set variable  ${operator.lower()}
    ${op}  Set Variable If  "${operator}"=="gt"    >
      ...    "${operator}"=="ge"   >=
      ...    "${operator}"=="lt"   <
      ...    "${operator}"=="le"   <=
      ...    "${operator}"=="ne"   !=
      ...    "${operator}"=="eq"   ==
      ...    unknown

    Run Keyword If  "${op}"=="unknown"   Fail  Unknown operator:${operator}

    ${cmd}  Set Variable  cat ${healing_log} | grep -E '(start VNF restart)|(triggering VNF restart)' | wc -l
    ${act_number}  OperatingSystem.Run  ${cmd}
    Should Be True   ${act_number}${op}${number}
    [Return]  ${number}


_VDU Get Pod Status
    [Arguments]    ${gnb_index}=0  ${vdu_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection   alias=${alias}
    ${alias}   get unique id
    Connect To K8s Master With Tenant Interactively   vdu_index=${vdu_index}   alias=${alias}   gnb_index=${gnb_index}
    ${out}  issh.Execute   command=oc get pod   alias=${alias}


Begin Auditlog On VDU
    [Documentation]    Begin Auditlog On VDU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    handle

    ...    Example
    ...    | ${handle} | Begin Auditlog On VDU |  |
    ...    | sleep  | 5 |
    ...    | ${local_auditlog} | Get A File | auditlog |   auditlog.log  |
    ...    |  End Auditlog On VDU |  log_dst_path=${local_auditlog} | handle=${handle} |
    ...
    Log To Console  Begin Auditlog On VDU

    ${pod_abbr}   Set Variable   logservice
    ${container}  Set Variable   logstorageserver

    ${alias}  Get Unique Id
    Connect To K8s Master With Tenant Interactively  alias=${alias}

    ${full_pod}  Get Full Pod Name By Pod Abbreviation Interactively   pod_abbr=${pod_abbr}    alias=${alias}
    ${full_container}  Get Full Container Name By Container Abbreviation   ctr_abbr=${container}

    ${remote_file_name}   Get A Remote File   auditlog   auditlog.log   alias=${alias}
    ${cmd}  Set Variable
    ...    kubectl exec -it ${full_pod} -c ${full_container} -- tail -f /var/log/audit/auditlog > ${remote_file_name}

    issh.Execute_bare   command=${cmd}   alias=${alias}
    Send ENTER Interactively   alias=${alias}

    ${handle}  Set Variable   ${alias}_${remote_file_name}
    [Return]   ${handle}


End Auditlog On VDU
    [Arguments]   ${log_dst_path}   ${handle}
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection     alias=${alias}
    [Documentation]   End Auditlog On VDU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | local_pcap  |  Yes | local_pcap file name|
    ...    | log_dst_path  |  Yes | log file name to be saved to UTE server |
    ...    | handle  |  Yes | handle return from 'Begin Auditlog On VDU' |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | ${handle} | Begin Auditlog On VDU |  |
    ...    | sleep  | 5 |
    ...    | ${local_auditlog} | Get A File | auditlog |   auditlog.log  |
    ...    |  End Auditlog On VDU |  log_dst_path=${local_auditlog} | handle=${handle} |
    ...
    Log To Console   End Auditlog On VDU
    ${alias}   set variable    ${handle.split('_')[0]}
    ${log_src_path}   set variable    ${handle.replace("${alias}_","")}

    Sleep  2
    Send CTRL_C Interactively    alias=${alias}
    Sleep  2

    ${out}    issh.Execute     command=sync   check_result=${False}    alias=${alias}
    ${out}    issh.Execute     command=ls -l ${log_src_path}     check_result=${False}  alias=${alias}

    issh.Download File   remote_path=${log_src_path}    local_path=${log_dst_path}   alias=${alias}
