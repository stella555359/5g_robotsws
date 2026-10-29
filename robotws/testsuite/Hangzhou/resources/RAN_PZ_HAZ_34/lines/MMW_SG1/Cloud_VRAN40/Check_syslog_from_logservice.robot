*** Settings ***
Documentation
...    Author: Ding Binmei
...    This is for log check from logservice pod

Library    taf.rfrl.cbts.connections.ssh_connections.SSHConnExec   WITH NAME   cbts_ssh_conn


*** Keywords ***
_Main Functions for search
    Connect to vdu host
    Start to collect log from logservice pod on VDU
    Stop log collection from logservice pod on VDU and download log to local
    Get pod and container name from VDU

Connect to vdu host
    [Documentation]    Author: Ding Binmei
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${conn_alias}=gnb${gnb_index}_du${gnb_index}_master
    csn.Connect_To
    ...  hostname=${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ...  username=${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ...  password=${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    ...  alias=${conn_alias}

Is log collection process exist
    [Documentation]    Author: Ding Binmei
    ...    Return with ${True} / ${False}
    [Arguments]    ${filter}    ${gnb_index}=0     ${vdu_index}=0    ${conn_alias}=gnb${gnb_index}_du${vdu_index}_master
    ${cmd_check_process}    Set variable    ps -ef | grep '${filter}' | grep -v grep
    ${is_process_exist}   csn.execute    command=${cmd_check_process}   connection=${conn_alias}
    ${is_process_exist}    Run keyword and return status    Should not be empty  ${is_process_exist.strip()}
    [Return]    ${is_process_exist}

Kill log collection process if exist
    [Documentation]    Author: Ding Binmei
    ...    param filter: filter for find the process. e.g.
    ...    -- kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${namespace} -- tail -F /var/log/localvolume/syslog
    [Arguments]    ${filter}    ${gnb_index}=0     ${vdu_index}=0    ${conn_alias}=gnb${gnb_index}_du${gnb_index}_master
    ${is_process_exist_before}    Is log collection process exist    filter=${filter}    gnb_index=${gnb_index}     vdu_index=${vdu_index}
    ...    conn_alias=${conn_alias}
    Return from keyword if    ${is_process_exist_before}==${False}
    ${cmd_kill_start_log_process}    Set variable    pkill -9 -f '${filter}'
    csn.execute    command=${cmd_kill_start_log_process}   connection=${conn_alias}
    Sleep   200ms    wait for process to be killed
    ${is_process_exist_after}    Is log collection process exist    filter=${filter}    gnb_index=${gnb_index}     vdu_index=${vdu_index}
    ...    conn_alias=${conn_alias}
    Should not be true    ${is_process_exist_after}

Get pod and container name from VDU
    [Documentation]    Author: Ding Binmei
    ...    connection is not the same with taf.transport.ssh, so rewrite keyword with connection newly added
    [Arguments]    ${pod_abbr}    ${container_abbr}    ${gnb_index}=0     ${vdu_index}=0
    ${namespace}     set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.namespace}
    cbts_ssh_conn.connect_to_vdu_cloud_hosting    using_tenant=${True}    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${pod_full_name}    ${container_full_name}    cbts_ssh_conn.get_full_pod_and_container_name    pod_abbr=${pod_abbr}
    ...    container_abbr=${container_abbr}    namespace=${namespace}
    [Return]    ${pod_full_name}    ${container_full_name}
    [Teardown]    cbts_ssh_conn.disconnect_vdu_cloud_hosting

Start to collect log from logservice pod on VDU
    [Documentation]    Author: Ding Binmei
    ...    param log_name: e.g: l2rt_logs.txt
    ...    param logs_filter: filter to grep logs in logservice. e.g.: SentDataMeasurementCounting\\|UlCounterUpdate
    [Arguments]    ${log_name}    ${gnb_index}=0     ${vdu_index}=0    ${conn_alias}=gnb${gnb_index}_du${gnb_index}_master
    ...    ${logs_filter}=${EMPTY}
    Connect to vdu host    gnb_index=${gnb_index}    vdu_index=${vdu_index}    conn_alias=${conn_alias}
    ${namespace}     set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.namespace}
    ${log_path_on_vdu}   Join Path   /tmp   ${log_name}
    ${pod_full_name}    ${container_full_name}    Get pod and container name from VDU    pod_abbr=logservice
    ...    container_abbr=logstorageserver    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${base_command}    Catenate    kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${namespace} --
    ...    tail -F /var/log/localvolume/syslog
    ${cmd_filter_log_and_store_in_file}    set variable    nohup ${base_command}|grep -ai "${logs_filter}" > ${log_path_on_vdu} 2>&1 &
    Wait Until Keyword Succeeds    3x    200ms    Kill log collection process if exist    filter=${base_command}    gnb_index=${gnb_index}
    ...    vdu_index=${vdu_index}    conn_alias=${conn_alias}
    csn.execute    command=rm -rf ${log_path_on_vdu}   connection=${conn_alias}
    FOR    ${retry}    IN RANGE    ${3}
        csn.send_command    command=${cmd_filter_log_and_store_in_file}   connection=${conn_alias}
        Sleep    1 sec    wait for process to be started
        ${status}    run keyword and return status    Wait Until Keyword Succeeds    5 sec    1 sec    _Verify log collection process is started
        ...    base_command=${base_command}    gnb_index=${gnb_index}    vdu_index=${vdu_index}    conn_alias=${conn_alias}
        exit for loop if    ${status}
    END
    [Return]    ${log_path_on_vdu}

_Verify log collection process is started
    [Documentation]    Author: Ding Binmei
    [Arguments]    ${base_command}    ${gnb_index}=0     ${vdu_index}=0    ${conn_alias}=gnb${gnb_index}_du${gnb_index}_master
    ${is_process_exist}    Is log collection process exist    filter=${base_command}    gnb_index=${gnb_index}     vdu_index=${vdu_index}
    ...    conn_alias=${conn_alias}
    Should be true   ${is_process_exist}

_Verify log collection process is stopped
    [Documentation]    Author: Lingxue Cui
    [Arguments]    ${base_command}    ${gnb_index}=0     ${vdu_index}=0    ${conn_alias}=gnb${gnb_index}_du${gnb_index}_master
    ${is_process_exist}    Is log collection process exist    filter=${base_command}    gnb_index=${gnb_index}     vdu_index=${vdu_index}
    ...    conn_alias=${conn_alias}
    should_not_be_true   ${is_process_exist}

Stop to collect log from logservice pod on VDU
    [Documentation]    Author: Ding Binmei
    [Arguments]    ${gnb_index}=0     ${vdu_index}=0    ${conn_alias}=gnb${gnb_index}_du${gnb_index}_master
    ${pod_full_name}    ${container_full_name}    Get pod and container name from VDU    pod_abbr=logservice
    ...    container_abbr=logstorageserver    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${namespace}     set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.namespace}
    ${base_command}    Catenate    kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${namespace} --
    ...    tail -F /var/log/localvolume/syslog
    Wait Until Keyword Succeeds    3x    200ms    Kill log collection process if exist    filter=${base_command}    gnb_index=${gnb_index}
    ...    vdu_index=${vdu_index}    conn_alias=${conn_alias}

Stop log collection from logservice pod on VDU and download log to local
    [Documentation]    Author: Ding Binmei
    [Arguments]    ${log_path_on_vdu}    ${local_log_directory}=${TS_CASE_LOG_PATH}    ${gnb_index}=0     ${vdu_index}=0
    ...    ${conn_alias}=gnb${gnb_index}_du${gnb_index}_master
    Stop to collect log from logservice pod on VDU    gnb_index=${gnb_index}    vdu_index=${vdu_index}    conn_alias=${conn_alias}
    ${local_log_path}    AiC_log_Collect.Download Log From OCP Master to Local     remote_full_log_path=${log_path_on_vdu}   conn_alias=${conn_alias}
    ...       log_local_dir=${local_log_directory}
    [Return]    ${local_log_path}
    [Teardown]    Run keywords    Stop to collect log from logservice pod on VDU    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ...    conn_alias=${conn_alias}    AND
    ...    csn.disconnect    connection=${conn_alias}
