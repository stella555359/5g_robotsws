*** Settings ***
Documentation    Suite description
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Resource    ./Check_syslog_from_logservice.robot
Resource    ./AIC_log_collect_via_webEM.robot


*** Keywords ***
_Main Functions for search
    Start Tcpdump Collector on OCP Master
    Stop Kubectl Log and Download From vDU OCP Master
    Stop Kubectl Log and Download From OCP Master Through ssh
#    Bellow methods are only valid for single L2RT pods, if multiple pods exist, need to use methods in Check_syslog_from_logservice instead
#    Capturing Kubectl Log with Duration on OCP Master
#    Start Collect L2RT Kubectl Log on vDU OCP Master Through ssh
#    Start Kubectl Log on vDU OCP Master through ssh
#########F1AP log is no longer supported from tcpdump. Please refer to methods in AIC_log_collect_via_webEM.robot
#    Start F1AP Log On vCU OCP Master

_Get vCU OCP Master SSH Connection Info
    [Documentation]  This keyword is used to get vCU ssh count. one gnb just have one vCU, so vCU index no need
    ...  *AUTHOR: dandan.fang@nokia-sbell.com
    [Arguments]     ${gnb_index}=0
    #For vCU, default use tenant account
    ${vCU_k8s_ssh_account}    Create Dictionary
    ...    host=${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ...    user=${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    ...    port=${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.port}
    [Return]   ${vCU_k8s_ssh_account}

Get vCU Namespace
    [Documentation]  This keyword is used to get vCU namespace, for example tl2114
    ...  *AUTHOR: dandan.fang@nokia-sbell.com
    [Arguments]     ${gnb_index}=0
    ${vcu_namespace}     set variable
    ...     ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.namespace}
    [Return]   ${vcu_namespace}

_Get vDU OCP Master SSH Connection Info
    [Documentation]  This keyword is used to get vCU ssh count. one gnb just have one vCU, so vCU index no need
    ...  *AUTHOR: dandan.fang@nokia-sbell.com
    [Arguments]     ${gnb_index}=0    ${vdu_index}=0
    #For vDU, default use core account
    ${vDU_k8s_ssh_account}    Create Dictionary
    ...    host=${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ...    user=${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    ...    port=${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.port}
    [Return]  ${vDU_k8s_ssh_account}

_Connect To OCP Master Through SSH
    [Arguments]  ${ssh_account}     ${conn_alias}=default    ${timeout}=30s
    [Documentation]    Connect To OCP Cluster Through SSH
    ...    *AUTHOR* dandan.fang@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | ssh_account       | Yes | ssh_account, host, uuser, password used to setup connection |
    ...    | connection_alias  | Yes | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    connection_alias. used to disconnect
    ...
    csn.Connect_To
    ...  hostname=${ssh_account}[host]
    ...  username=${ssh_account}[user]
    ...  password=${ssh_account}[password]
    ...  alias=${conn_alias}
    ...  timeout=${timeout}
    Set Suite Variable    ${conn_alias}
    [Return]   ${conn_alias}

# Start F1AP Log On vCU OCP Master
#     [Documentation]  This keyword is used to start collecting k8s f1ap logs from vCU
#     ...  *AUTHOR: dandan.fang@nokia-sbell.com
#     ...
#     ...    |    Input Parameters     | Man. | Description |
#     ...    |   gnb_index             | No  |  gnb index in testline configurtion file. Default is 0.  |
#     ...    *RETURN VALUE*
#     ...   f1ap_collector_alias
#     [Arguments]      ${gnb_index}=0    ${f1ap_collector_alias}=gNB${gnb_index}_vcu_f1ap
#     ${ssh_info}       _Get vCU OCP Master SSH Connection Info     gnb_index=${gnb_index}
#     ${vcu_namespace}     set variable
#     ...     ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.namespace}
#     ${f1ap_collector_alias}      Start Tcpdump Collector on OCP Master
#     ...       pod_name=po-cpif-0     container_name=ctr-nwmgmt
#     ...       namespace=${vcu_namespace}   tcpdump_alias=${f1ap_collector_alias}
#     ...       executor_master_ssh_account=${ssh_info}

Start Tcpdump Collector on OCP Master
    [Documentation]  This keyword is used to start collecting k8s tcpdump logs for vCU or vDU
    ...  *AUTHOR: dandan.fang@nokia-sbell.com
    ...
    ...    |    Input Parameters               | Man. | Description |
    ...    |   pod_name                        | Yes  | full pod name, such as po-cran1-up-0.            |
    ...    |   container_name                  | Yes  | full container name, such as ctr-cran1-l2rt.     |
    ...    |   executor_master_ssh_account     | Yes  |  Collector name, such as vcu_tcpdump_cpif        |
    ...    |   namespace                       | Yes  | K8 system and user namespace                     |
    ...    |   tcpdump_alias                   | Yes  | alias name for the tcpdump collection            |
    ...    *RETURN VALUE*
    ...   k8s_tcpdump_collection_alias
    ...   Reference: INterface - create_k8s_kubectl_tcpdump_collector
    ...   Reference: /opt/ute/python3/lib/python3.6/site-packages/taf/collectors/tcpdump/interface.py
    [Arguments]
    ...          ${tcpdump_alias}  ${namespace}
    ...          ${pod_name}   ${container_name}   ${executor_master_ssh_account}
    # -vv print detail information of packages
    tcpdump.create_k8s_kubectl_tcpdump_collector
    ...     name=${tcpdump_alias}
    ...     options=sctp -i any -p -n -w - -vv
    ...     kubectl_exec_options=-n ${namespace} ${pod_name} -c ${container_name}
    ...     executor=${executor_master_ssh_account}

    #set_test_alias need to be called, else maybe meet collector as nontype issue
    tcpdump.set_suite_alias   alias=${tcpdump_alias}
    tcpdump.setup_collectors    names=${tcpdump_alias}
    tcpdump.start_collectors    names=${tcpdump_alias}
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    Log to console    Start Tcpdump Log on OCP Master+${timestamp}
    [Return]  ${tcpdump_alias}

#Capturing Kubectl Log with Duration on OCP Master
#    [Documentation]    Author: Dandan Fang
#    ...      Refer to Capturing Aasyslog with duration
#    ...      Keep capturing Kubectl L2RT Log for given duration.
#    ...    | logs_filter             | No  |  the save log can add filter to aviod too large |
#    [Arguments]
#    ...            ${gnb_index}=0    ${vdu_index}=0     ${k8_conn}=gnb${gnb_index}_du${gnb_index}_master
#    ...            ${duration}=20s    ${log_name}=Kubectl_L2RT_Log_with_duration.txt   ${logs_filter}=${EMPTY}
#    ${k8log_pid}    ${k8log_full_log_path}    Start Collect L2RT Kubectl Log On VDU OCP Master Through Ssh
#    ...      log_name=${log_name}     gnb_index=${gnb_index}   vdu_index=${vdu_index}   logs_filter=${logs_filter}
#
#    sleep    ${duration}    msg=Waiting captuing L2RT Kubectl capturing
#    ${local_path}=    Stop Kubectl Log and Download From vDU OCP Master    remote_full_log_path=${k8log_full_log_path}
#    ...      pid=${k8log_pid}    conn_alias=${k8_conn}
#    [Return]    ${local_path}

#Start Collect L2RT Kubectl Log on vDU OCP Master Through ssh
#    [Documentation]  This keyword is used to start to captur k8 logs for L2RT
#    ...  *AUTHOR: dandan.fang@nokia-sbell.com
#    ...
#    ...    |    Input Parameters     | Man. | Description |
#    ...    |   gnb_index             | no  |  gnb index in testline configurtion file. Default is 0.  |
#    ...    |   vdu_index             | no  |  vdu index in testline configurtion file. Default is 0.  |
#    ...    |   log_name              | no  |  specific log name  ,default l2rt_k8slog  |
#    ...    |   remote_dir            | no  |  need to be as 'tmp' , the path need to be real present with K8 OCP.  |
#    ...    | logs_filter             | No  |  the save log can add filter to aviod too large |
#    ...    *RETURN VALUE*
#    ...   k8slog_pid    remote_full_log_path    connection_alias
#    [Arguments]     ${gnb_index}=0    ${vdu_index}=0   ${log_name}=l2rt_k8slog.txt
#    ...             ${du_master_conn}=gnb${gnb_index}_du${gnb_index}_master   ${logs_filter}=${EMPTY}
#    ${k8slog_pid}   ${remote_full_log_path}     Start Kubectl Log On VDU OCP Master Through Ssh
#    ...       pod_name=l2rt       container_name=l2rt
#    ...       log_name=${log_name}
#    ...       gnb_index=${gnb_index}    vdu_index=${vdu_index}   conn_alias=${du_master_conn}  logs_filter=${logs_filter}
#    [Return]    ${k8slog_pid}   ${remote_full_log_path}

#Start Kubectl Log on vDU OCP Master through ssh
#	[Documentation]
#    ...    *AUTHOR* dandan.fang@nokia-sbell.com
#    ...    |  Input Parameters       | Man. | Description |
#    ...    | pod_name                | Yes | pod name, l2rt or l2hi or others |
#    ...    | container_name          | Yes | pod name, l2rt or l2hi or others ,please make sure it is included by the pod|
#    ...    | log_name                | Yes | special log, please define specific log name |
#    ...    | gnb_index               | No  |  gnb index in testline configurtion file. Default is 0.  |
#    ...    | vdu_index               | No  |  vdu index in testline configurtion file. Default is 0.  |
#    ...    | connection_alias        | No  |  need to be as 'default' , else AliasLookupError: 'Default alias used, but no object set as default.' |
#    ...    | logs_filter             | No  |  the save log can add filter to aviod too large |
#    ...    *RETURN VALUE*
#    ...    k8slog_pid    remote_full_log_path.
#    [Arguments]
#    ...    ${pod_name}   ${container_name}     ${log_name}       ${since_time}=1s
#    ...    ${gnb_index}=0   ${vdu_index}=0   ${conn_alias}=gnb${gnb_index}_du${gnb_index}_master    ${logs_filter}=${EMPTY}
#    ${vdu_ssh}     _Get vDU OCP Master SSH Connection Info  gnb_index=${gnb_index}   vdu_index=${vdu_index}
#    ${conn_alias}    _Connect To OCP Master Through SSH     ssh_account=${vdu_ssh}   conn_alias=${conn_alias}
#    ${namespace}     set variable        ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.namespace}
#    ${full_pod_name}     set variable     po-${namespace}-${pod_name}-0
#    ${full_container_name}     set variable     ctr-${namespace}-${container_name}
#
#    ${remote_full_log_path}   Join Path   /tmp   ${log_name}
#    csn.send_command    rm -rf ${remote_full_log_path}  connection=${conn_alias}
#
#    ${base_command} =   catenate  SEPARATOR=${EMPTY}
#    ...      kubectl logs -f -n ${namespace} ${full_pod_name} --since=${since_time} -c ${full_container_name}
#
#    csn.execute    command=pkill -9 -f '${base_command}'  connection=${conn_alias}
#    ${pid_checked_after_killed}   csn.execute    command=ps -ef | grep '${base_command}' | grep -v grep   connection=${conn_alias}
#    ${pid_checked_after_killed}    strip_string    ${pid_checked_after_killed}
#    Should Be Empty  ${pid_checked_after_killed}    msg=please make sure no kubectl logs on same pod same container before start new.
#
#    # nohup is not work for kubectl logs
#    ${run_command}   set variable      ${base_command} | grep -a "${logs_filter}" >${remote_full_log_path}
#
#    ${k8slog_pid}   Wait Until Keyword Succeeds    2 min    5s
#    ...    Run Command and Verify Process Present      run_command=${run_command}   process_filter=${base_command}
#    ...    conn_alias=${conn_alias}
#
#    [Return]   ${k8slog_pid}   ${remote_full_log_path}

Run Command and Verify Process Present
    [Documentation]    Author: Dandan Fang
    ...    |  Input Parameters       | Man. | Description |
    ...    | run_command             | Yes  |  defailt command that will be send to system through ssh. |
    ...    | process_filter             | No  |  info used to get process id |
    ...   Note: awk '$6!~/pts/' is used to ignore "pseudo-terminal slave"
    [Arguments]   ${run_command}   ${process_filter}   ${conn_alias}
    csn.send_command   command=${run_command}   connection=${conn_alias}
    ${pid}   csn.execute    command=ps -ef | grep '${process_filter}' | grep -v grep | awk '{print $2}'   connection=${conn_alias}
    ${pid}    strip_string    ${pid}
    Should Not Be Empty  ${pid}   msg=No related pid found, Need to check Manual.
    ${pid_is_int}           Evaluate     isinstance(${pid}, int)
    Should Be True   ${pid_is_int}
    [Return]     ${pid}

Stop Kubectl Log and Download From vDU OCP Master
    [Arguments]    ${pid}   ${remote_full_log_path}   ${conn_alias}
    [Documentation]
    ...    *AUTHOR* dandan.fang@nokia-sbell.com
    ...    Arguments explanation, please refer kw "Stop kubectl log and download from Cluster through ssh"
    ${full_log_path}    Stop Kubectl Log and Download From OCP Master Through ssh
    ...     conn_alias=${conn_alias}
    ...     pid=${pid}    remote_full_log_path=${remote_full_log_path}
    [Return]    ${full_log_path}
    [Teardown]    csn.disconnect   connection=${conn_alias}

Stop Kubectl Log and Download From OCP Master Through ssh
	[Documentation]
    ...    *AUTHOR* dandan.fang@nokia-sbell.com
    ...    |  Input Parameters           | Man. | Description |
    ...    | pid                         | Yes | process id not empty.use to kill it after logs downloaded |
    ...    | local_dir                   | Yes | the log dir in local machine   |
    ...    | local_log_name              | Yes | log name, please define specific one log  |
    ...    | remote_full_log_path        | Yes | remote log path+log name  |
    ...    | connection_alias        | No  |  need to be as 'default' , else AliasLookupError: 'Default alias used, but no object set as default.' |
    ...    *RETURN VALUE*
    ...    full_log_path.
    [Arguments]    ${pid}   ${remote_full_log_path}   ${conn_alias}=default
    return from keyword if    '${pid}'=='${EMPTY}'
    ${output} =  csn.Execute    command=kill -9 ${pid}    connection=${conn_alias}
    should not contain    ${output}    No such process
    ${local_full_dir}    Download Log From OCP Master to Local
    ...       remote_full_log_path=${remote_full_log_path}    conn_alias=${conn_alias}
    [Return]    ${local_full_dir}

Download Log From OCP Master to Local
	[Documentation]
    ...    *AUTHOR* dandan.fang@nokia-sbell.com
    ...    |  Input Parameters           | Man. | Description |
    ...    | log_local_dir                   | Yes | the log dir in local machine, default value ${TS_CASE_LOG_PATH}   |
    ...    | remote_full_log_path        | Yes | remote log path+log name  |
    ...    | connection_alias        | No  |  need to be as 'default' , else AliasLookupError: 'Default alias used, but no object set as default.' |
    ...    *RETURN VALUE*
    ...    local_full_dir.
    [Arguments]     ${remote_full_log_path}   ${conn_alias}=default
    ...       ${log_local_dir}=${TS_CASE_LOG_PATH}
    ${is_remore_file_empty}    ssh_common_commands.is_file_empty    file_path=${remote_full_log_path}    connection=${conn_alias}
    Should Not Be True    ${is_remore_file_empty}    msg=Captured ${remote_full_log_path} is empty, please double check
    ${remote_dir_list}      Split String     ${remote_full_log_path}    separator=/
    ${local_log_name}   set variable    ${remote_dir_list[-1]}
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${local_full_dir}=    Join Path         ${log_local_dir}     ${timestamp}_${local_log_name}
    Create File   ${local_full_dir}
    csn.download_file    remote_path=${remote_full_log_path}    local_path=${local_full_dir}  connection=${conn_alias}
    sleep    20s  reason=Wait for file download
    File should not be empty   path=${local_full_dir}    msg=Captured ${local_full_dir} is empty, please double check
    csn.send command    command=rm -rf ${remote_full_log_path}    connection=${conn_alias}
    [Return]    ${local_full_dir}

collect vdu logs on ocp
    [Documentation]    Author: Lingxue Cui
    ...     This keyword will use kuafu tool to collect vdu log on du ocp.
    ...     ${kuafu_root_dir}:  specify the absolute path where kuafu tool is installed.
    ...     ${log_type}: supported log type: startup/journal/syslog/symptomreport/snapshot, if multi log types are required, seperate by coomma
    [Arguments]    ${log_type}=startup,syslog    ${gnb_index}=0     ${vdu_index}=0
    ...    ${connection}=gnb${gnb_index}_du${gnb_index}_master    ${local_dir}=${TS_CASE_LOG_PATH}    ${remove_remote_file}=${True}

    Connect to vdu host    gnb_index=${gnb_index}    vdu_index=${vdu_index}    conn_alias=${connection}
    ${cmd_find_kuafu_script}     set variable    find /var/home -name kuafu.sh 2>/dev/null
    csn.send_command    command=${cmd_find_kuafu_script}   connection=${connection}
    ${kuafu_script_path}    csn.read_output     connection=${connection}
    ${kuafu_script_path}    strip_string    ${kuafu_script_path}
    ${kuafu_script_split}    split_string_from_right   ${kuafu_script_path}     /    max_split=1
    ${kuafu_root_dir}    set variable    ${kuafu_script_split[0]}

    ${kuafu_log_dir}    set variable    ${kuafu_root_dir}/logs/vdu
    ${cmd_vdu_log_collect}    set variable if    '${log_type}'=='all'    nohup ${kuafu_script_path} -a vdu_log_collect 2>&1 &
    ...    nohup ${kuafu_script_path} -a vdu_log_collect -p ${log_type} 2>&1 &
    ${cmd_get_current_file_number}    set variable    find ${kuafu_log_dir} -maxdepth 1 -type f | wc -l
    ${cmd_get_latest_file_path}    set variable   find ${kuafu_log_dir} -maxdepth 1 -type f -printf '%T+ %p\n' | sort -r | head -n 1 | cut -d' ' -f2-

    csn.send_command    command=${cmd_get_current_file_number}   connection=${connection}
    ${file_number_before}    csn.read_output     connection=${connection}

    FOR    ${retry}    IN RANGE    ${3}
        ${is_collection_started}    set variable    init
        csn.send_command    command=${cmd_vdu_log_collect}   connection=${connection}
        ${output}     csn.read_output   connection=${connection}
#        Sleep    1 sec    wait for process to be started
        ${status}    run keyword and return status    Wait Until Keyword Succeeds    5 sec    1 sec    _Verify log collection process is started
        ...    base_command=vdu_log_collect    gnb_index=${gnb_index}    vdu_index=${vdu_index}    conn_alias=${connection}
        Exit For Loop If    ${status}

        csn.send_command    command=${cmd_get_current_file_number}   connection=${connection}
        ${file_number_after}    csn.read_output     connection=${connection}
        Exit For Loop If    ${file_number_after.strip()}>${file_number_before.strip()}
        ${is_collection_started}    set variable    ${False}
    END
    run keyword if    '${is_collection_started}'=='${False}'    Fail    msg=vdu log collection is not started.

    Wait Until Keyword Succeeds    10 min    1 sec    _Verify log collection process is stopped
    ...    base_command=vdu_log_collect    gnb_index=${gnb_index}    vdu_index=${vdu_index}    conn_alias=${connection}
    csn.send_command    command=${cmd_get_latest_file_path}   connection=${connection}
    ${vdu_log_path}    csn.read_output     connection=${connection}
    Download file to testPC    remote_file_path=${vdu_log_path.strip()}    connection=${connection}    local_dir=${local_dir}
    ...    remove_remote_file=${remove_remote_file}
    [Teardown]    run keyword and ignore error    csn.disconnect    connection=${connection}

collect multiple vdu logs on ocp
    [Documentation]    Author: Lingxue Cui
    [Arguments]    ${log_type}=startup,syslog    ${gnb_index}=0     ${du_index_list}=${LIST_DU_INDEX_0}
    ...    ${local_dir}=${TS_CASE_LOG_PATH}    ${remove_remote_file}=${True}
    ${du_index_list}    string_list.string2list    ${du_index_list}
    FOR    ${du_index}    IN    @{du_index_list}
           run keyword and continue on failure    collect vdu logs on ocp
           ...    log_type=${log_type}    local_dir=${local_dir}    remove_remote_file=${remove_remote_file}
           ...    gnb_index=${gnb_index}    vdu_index=${du_index}
    END
