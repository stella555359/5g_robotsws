*** Settings ***
Documentation
...    Author:    Wu Amy;Zhou Qiang;Ding Lisa
...    Maintainer:    Wu Amy;Zhou Qiang;Ding Lisa

Resource    ../bts/aic_bts_common_oam.robot

Library    OperatingSystem
Library    DateTime

Library    ../../python/log/basic_system_operation.py    WITH NAME    basic_system_operation
Library    ../../python/log/collect_k8s_log_func.py    WITH NAME    k8s_func
Library    ../../python/log/collect_bip_log_func.py    WITH NAME    bip_func
Library    ../../python/log/collect_wireshark_log_func.py    WITH NAME    wireshark_func
Library    ../../python/log/collect_tti_log_func.py    WITH NAME    collect_tti_log_func
Library    ../../python/log/dcap_func.py    WITH NAME    dcap_func

Library    taf.transport.ssh    WITH NAME    tafssh
Library    taf.hw.fhgw.cli    WITH NAME    issh
Library    taf.gnb.oam.coam.cu.interface.cu    WITH NAME    cu
Library    taf.gnb.oam.coam.vdu.interface.Vdu    WITH NAME    vdu

*** Keywords ***
#------------------------------------------common-------------------------------------------------
SISO Capture AIC Log
    [Arguments]    ${Flag}    ${cu_list}=${CU_LIST}    ${vdu_list}=${VDU_LIST}    ${container_name}=${EMPTY}
    ...    ${pod_name}=${EMPTY}    ${pod_prefix}=${EMPTY}    ${container_prefix}=${EMPTY}    ${protocol}=${EMPTY}

    ${container_name}    Set Variable If    '${container_name}' == '${EMPTY}'    l2rt    ${container_name}
    ${pod_name}    Set Variable If    '${pod_name}' == '${EMPTY}'    l2rt    ${pod_name}
    ${pod_prefix}    Set Variable If    '${pod_prefix}' == '${EMPTY}'    po-cran1    ${pod_prefix}
    ${container_prefix}    Set Variable If    '${container_prefix}' == '${EMPTY}'    ctr-cran1    ${container_prefix}
    ${protocol}    Set Variable If    '${protocol}' == '${EMPTY}'    sctp    ${protocol}

    Run Keyword If    '${Flag}' == 'snapshot_cu'    Save Local Snapshot In vCU With Diff Status    ${cu_list}
    ...    ELSE IF    '${Flag}' == 'snapshot_du'    Save Local Snapshot In vDU With Diff Status    ${vdu_list}
    ...    ELSE IF    '${Flag}' == 'k8s_cu'    SISO Collect And Download K8s Log In vCU    ${cu_list}
    ...    ${container_name}    ${pod_name}
    ...    ELSE IF    '${Flag}' == 'k8s_du'    SISO Collect And Download K8s Log In vDU    ${vdu_list}
    ...    ${container_name}    ${pod_name}
    ...    ELSE IF    '${Flag}' == 'bip'    SISO Start Bip Log    ${vdu_list}    ${container_name}    ${pod_name}
    ...    ${pod_prefix}    ${container_prefix}    ${pod_name}
    ...    ELSE IF    '${Flag}' == 'syslog_cu'    SISO Collect Syslog In Cu    ${cu_list}
    ...    ELSE IF    '${Flag}' == 'syslog_du'    SISO Collect Syslog In vDu    ${vdu_list}
    ...    ELSE IF    '${Flag}' == 'wireshark_cu'    SISO Start Wireshark Log In vCU    ${cu_list}
    ...    ${container_name}    ${pod_name}    timeout=${10}    protocol=${protocol}    interface=any
    ...    ELSE IF    '${Flag}' == 'wireshark_du'    SISO Start Wireshark Log In vDU    ${cu_list}   ${container_name}
    ...    ${pod_name}    timeout=${10}    protocol=${protocol}   interface=${any}
    ...    ELSE    SISO Start TTI Log In vDU    ${vdu_list}

SISO Connect To vDU K8s Master
    [Arguments]    ${gnb_index}=${EMPTY}    ${vdu_index}=${EMPTY}    ${alias}=default
    ${gnb_index_act}    Set Variable If    '${gnb_index}' == '${EMPTY}'    CU_0    ${gnb_index}
    ${vdu_index_act}    Set Variable If    '${vdu_index}' == '${EMPTY}'    vDU_0    ${vdu_index}
    ${vdu_k8s_master_ssh_connection_info}    Get K8s Master SSH Connection Info In vDU    gnb_index=${gnb_index_act}
    ...    vdu_index=${vdu_index_act}
    ${ip}    Set Variable    ${vdu_k8s_master_ssh_connection_info["addr"]}
    ${username}    Set Variable    ${vdu_k8s_master_ssh_connection_info["username"]}
    ${password}    Set Variable    ${vdu_k8s_master_ssh_connection_info["password"]}

    ${prompt}    Set Variable
    ...    \\[cloudadmin@\\S+\\s\\S+\\]\\$|\\[root@\\S+\\s\\S+\\s+\\S+\\]\\#|\\[root@\\S+\\s\\S+\\]\\#
    ${prompt}    Set Variable    ${prompt}|\\[cbis-admin@\\S+\\s\\S+\\s+\\S+\\]\\$|\\[cbis-admin@\\S+\\s\\S+\\]\\$
    ${prompt}    Set Variable    ${prompt}|\\[core@\\S+\\s\\S+\\]\\$
    ${prompt}  Set Variable   ${prompt}|\\[cranuser\\d+@\\S+\\s+\\S+\\]\\$|\\[cranuser\\d+@\\S+\\s+\\S+\\s+\\S+\\]\\$
    issh.Connect_To    ip=${ip}    username=${username}    password=${password}
       ...   prompt=${prompt}
       ...   alias=${alias}
       ...   width=200
       ...   timeout=150

#------------------------------------------snapshot------------------------------------------------
Save Local Snapshot In vCU With Diff Status
    [Arguments]     ${cu_list}=${CU_LIST}    ${local_snapshot_location}=vCU_Snapshot
    Log To Console   \n*** Start to save snapshot ***
    FOR    ${cu_index}    IN    @{cu_list}
        Login To CU By Rest    cu_index=${cu_index}
        ${Snapshot_path}    basic_system_operation.create_a_directory    log_path=${TEST_LOGS_DIR_PATH}
        ...                 directory_name=${local_snapshot_location}    cu_vdu_index=${cu_index}
        ${status}    cu.check_snapshot_status
        Run Keyword If    '${status}'=='idle'    cu.Get_Local_Snapshot    ${Snapshot_path}
        ...    ELSE IF    '${status}'=='local-ongoing'
        ...    SISO Save Local Ongoing Snapshot In vCU    file_path=${Snapshot_path}
        return from keyword    ${Snapshot_path}
    END
    [Teardown]    Run Keyword And Ignore Error    Logout To CU By Rest

SISO Save Local Ongoing Snapshot In vCU
    [Arguments]   ${file_path}=${Snapshot_path}
    ${information}    cu.get_snapshot_operations_information
    FOR    ${info}    IN    @{information}
        ${operation_id}    Set Variable    ${info['operation_id']}
        cu.get_local_snapshot_by_id    directory=${file_path}
        ...    operation_id=${operation_id}
        ...    operation_timeout=600
        ...    use_m2m=False
    END

Save Local Snapshot In vDU With Diff Status
    [Arguments]    ${vdu_list}=${VDU_LIST}    ${local_snapshot_location}=vDU_Snapshot
    log to console    Save Local Snapshot...
    FOR    ${vdu}    IN    @{vdu_list}
        ${cu_index}    ${vdu_index}    Split String    ${vdu}    -
        Login To vDU By Rest    vdu_index=${vdu_index}    cu_index=${cu_index}
        ${Snapshot_path}    basic_system_operation.create_a_directory    log_path=${TEST_LOGS_DIR_PATH}
        ...                 directory_name=${local_snapshot_location}    cu_vdu_index=${vdu}
        ${status}    vdu.check_snapshot_status
        Run Keyword If    '${status}'=='idle'    vdu.Get_Local_Snapshot    ${Snapshot_path}
        ...    ELSE IF    '${status}'=='local-ongoing'
        ...    SISO Save Local Ongoing Snapshot In vDU    file_path=${Snapshot_path}
        Return From Keyword    ${Snapshot_path}
    END
    [Teardown]    Logout To vDU By Rest

SISO Save Local Ongoing Snapshot In vDU
    [Arguments]   ${file_path}=${Snapshot_path}
    ${information}    vdu.get_snapshot_operations_information
    FOR    ${info}    IN    @{information}
        ${operation_id}     Set Variable    ${info['operation_id']}
        vdu.check_local_snapshot_status_and_save_it    directory=${file_path}
        ...    operation_id=${operation_id}
        ...    use_m2m=False
        ...    operation_timeout=600
        ...    compressed_or_not=True
    END

#--------------------------------------------K8S---------------------------------------------------
SISO Collect And Download K8s Log
    [Arguments]    ${gnb_index_default}=${EMPTY}    ${container_name_default}=${EMPTY}
    ...    ${pod_name_default}=${EMPTY}    ${namespace_default}=${EMPTY}
    ...    ${timeout}=${10}    ${duration}=${3m}    ${tmp_log_dir}=/tmp/
    ${gnb_index}    Set Variable If    '${gnb_index_default}' == '${EMPTY}'    0    ${gnb_index_default}
    ${container_name}    Set Variable If
    ...    '${container_name_default}' == '${EMPTY}'    l2rt    ${container_name_default}
    ${pod_name}    Set Variable If
    ...    '${pod_name_default}' == '${EMPTY}'    up    ${pod_name_default}
    ${namespace}    Set Variable If
    ...    '${namespace_default}' == '${EMPTY}'    cran1    ${namespace_default}
    ${hostname}    Set Variable
    ...    ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ${username}    Set Variable
    ...    ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ${password}    Set Variable
    ...    ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    ${conn}    basic_system_operation.master_connect
    ...    hostname=${hostname}
    ...    username=${username}
    ...    password=${password}
    ...    alias=master
    Set Test Variable    ${conn}
    ${remote_log_dir}=     k8s_func.collect_k8s_log
    ...    pod_name=${pod_name}
    ...    namespace=${namespace}
    ...    container_name=${container_name}
    ...    tmp_log_dir=${tmp_log_dir}
    ...    conn=master
    ...    timeout=${timeout}
    ...    duration=${duration}
    ${local_file_path}=    basic_system_operation.create_a_file    ${TEST_LOGS_DIR_PATH}/${cu_index}/k8s
    ...    ${container_name}.log
    Set Test Variable    ${local_file_path}
    Set Test Variable    ${remote_log_dir}
    [Return]    ${local_file_path}    ${remote_log_dir}
    [Teardown]    Run keyword and ignore error    basic_system_operation.master_close    alias=master

SISO Collect And Download K8s Log In vDU
    [Arguments]    ${vdu_list}=${VDU_LIST}    ${container_name}=${EMPTY}    ${pod_name}=${EMPTY}
    ...          ${timeout}=${10}    ${duration}=60s    ${tmp_log_dir}=/tmp/
    FOR    ${vdu}    IN    ${vdu_list}
        ${cu_index}    ${vdu_index}    Split String    ${vdu}    -
        ${gnb_index}    Fetch From Right    ${cu_index}    _
        ${vdu_index}    Fetch From Right    ${vdu_index}    _
        ${namespace}=    Set Variable
        ...    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.namespace}
        Set Test Variable    ${ns}
        ${local_file_path}    ${remote_log_dir}=     SISO Collect And Download K8s Log
        ...    gnb_index_default=${gnb_index}
        ...    pod_name_default=${pod_name}
        ...    namespace_default=${namespace}
        ...    container_name_default=${container_name}
        ...    tmp_log_dir=${tmp_log_dir}
        ...    timeout=${timeout}
        ...    duration=${duration}
        Set Test Variable    ${local_file_path}
        SISO Connect To vDU K8s Master    gnb_index=${cu_index}
        ...    vdu_index=${vdu_index}
        ...    alias=default
        issh.Download File    remotes_path=${remote_log_dir}    local_path=${local_file_path}    alias=default
        Return From Keyword    ${local_file_path}
    END
    [Teardown]    Run keyword and ignore error    issh.disconnect    alias=default

SISO Collect And Download K8s Log In vCU
    [Arguments]    ${cu_list}=${CU_LIST}    ${container_name}=${EMPTY}    ${pod_name}=${EMPTY}
    ...    ${timeout}=${10}    ${duration}=60s    ${tmp_log_dir}=/tmp/
    FOR    ${cu_index}    IN    @{cu_list}
        ${gnb_index}    Fetch From Right    ${cu_index}    _
        ${namespace}=    Set Variable    ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.namespace}
        Set Test Variable    ${namespace}
        ${local_file_path}    ${remote_log_dir}=     SISO Collect And Download K8s Log
        ...    gnb_index_default=${gnb_index}
        ...    pod_name_default=${pod_name}
        ...    namespace_default=${namespace}
        ...    container_name_default=${container_name}
        ...    tmp_log_dir=${tmp_log_dir}
        ...    timeout=${timeout}
        ...    duration=${duration}
        Set Test Variable    ${local_file_path}
        ${alias}    basic_system_operation.master_connect    hostname=${hostname}
        ...    username=${username}
        ...    password=${password}
        ...    alias=master
        Set Test Variable    ${alias}
        tafssh.Download File    remote_path=${remote_log_dir}    local_path=${local_file_path}   connection=${alias}
        Return From Keyword   ${local_file_path}
    END
    [Teardown]    Run keyword and ignore error    basic_system_operation.master_close    alias=${alias}

SISO Check K8s Log
    [Arguments]    ${local_file_path}    ${k8slog_prints}    ${filter}=drx
    Log    Checking K8S log   console=True
    ${output}    OperatingSystem.Run    command=cat ${local_file_path} | grep -a "${filter}" | grep -av grep
    Should Not Be Empty    ${output}
    FOR    ${print}    IN    @{k8slog_prints}
         should contain    ${output}    ${print}
    END
    [Return]    ${output}

#--------------------------------------------BIP---------------------------------------------------
SISO Start Bip Log
    [Arguments]    ${vdu_list}=${VDU_LIST}    ${container_name_default}=${EMPTY}
    ...    ${pod_name_default}=${EMPTY}    ${pod_prefix_default}=${EMPTY}    ${container_prefix_default}=${EMPTY}
    ...    ${port_name_default}=${EMPTY}    ${timeout}=${10}

    ${container_name}    Set Variable If
    ...    '${container_name_default}' == '${EMPTY}'    l2rt    ${container_name_default}
    ${pod_name}    Set Variable If
    ...    '${pod_name_default}' == '${EMPTY}'    l2rt    ${pod_name_default}
    ${container_prefix}    Set Variable If
    ...    '${container_prefix_default}' == '${EMPTY}'    ctr-cran1    ${container_prefix_default}
    ${pod_prefix}    Set Variable If
    ...    '${pod_prefix_default}' == '${EMPTY}'    po-cran1    ${pod_prefix_default}
    ${port_name}    Set Variable If
    ...    '${port_name_default}' == '${EMPTY}'    l1bipl1    ${port_name_default}

    FOR    ${vdu}    IN    @{vdu_list}
        ${cu_index}    ${vdu_index}    Split String    ${vdu}    -
        ${gnb_index}    Fetch From Right    ${cu_index}    _
        ${vdu_index}    Fetch From Right    ${vdu_index}    _
        ${vdu_k8s_master_ssh_connection_info}    Get K8s Master SSH Connection Info In vDU    gnb_index=${gnb_index}
        ...    vdu_index=${vdu_index}
        ${ip}    Set Variable    ${vdu_k8s_master_ssh_connection_info["addr"]}
        ${username}    Set Variable    ${vdu_k8s_master_ssh_connection_info["username"]}
        ${password}    Set Variable    ${vdu_k8s_master_ssh_connection_info["password"]}

        ${conn}    basic_system_operation.master_connect    hostname=${ip}    username=${username}    password=${password}
        ...    alias=vdu_master
        Set Test Variable    ${conn}
        ${namespace}=    Set Variable    ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.namespace}
        Set Test Variable    ${namespace}
        ${port_id}    Set Variable  0
        Set Test Variable    ${alias_issh}    vdu_master_issh
        SISO Connect To vDU K8s Master    gnb_index=${gnb_index}
        ...    vdu_index=${vdu_index_act}    alias=${alias_issh}
        ${bip_cmd}=    Catenate  kubectl exec -it ${pod_prefix}-${pod_name}-0 -n ${namespace}
        ...     -c ${container_prefix}-${container_name} -- bash
        ...     -c 'dpdk-cli pdump port ${port_id} path /tmp/dpdkdump > /tmp/dpdkdump/start_bip.log 2>&1'
        issh.Execute_bare
        ...     command=${bip_cmd}
        ...     alias=${alias_issh}
        SISO Send ENTER Interactively    alias=${alias_issh}
    END
    Log    ${timeout}
    [Teardown]    Run keyword and ignore error    SISO Stop Bip Log And Download To K8s Master
    ...    alias_issh=${alias_issh}

SISO Send ENTER Interactively
    [Arguments]  ${alias}=default
    ${enter}    Evaluate    chr(int(13))
    ${output}   issh.Execute_Bare   command=${enter}     alias=${alias}
    Sleep    1.3s
    [Return]  ${output}

SISO Stop Bip Log
    [Arguments]  ${alias}=default
    ${output}   SISO Send CTRL_C Interactively     ${alias}
    [Return]  ${output}

SISO Send CTRL_C Interactively
    [Arguments]  ${alias}=default
    ${crtl_c}    Evaluate    chr(int(3))
    ${output}   issh.Execute_Bare   command=${crtl_c}     alias=${alias}
    Sleep    3s
    [Return]  ${output}

SISO Stop Bip Log And Download To K8s Master
    [Arguments]    ${cu_list}=${CU_LIST}    ${container_name_default}=${EMPTY}    ${pod_name_default}=${EMPTY}
    ...    ${pod_prefix_default}=${EMPTY}    ${container_prefix_default}=${EMPTY}    ${timeout}=${10}
    ...    ${alias_issh}=default
    ${container_name}    Set Variable If
    ...    '${container_name_default}' == '${EMPTY}'    l2rt    ${container_name_default}
    ${pod_name}    Set Variable If
    ...    '${pod_name_default}' == '${EMPTY}'    l2rt    ${pod_name_default}
    ${container_prefix}    Set Variable If
    ...    '${container_prefix_default}' == '${EMPTY}'    ctr-cran1    ${container_prefix_default}
    ${pod_prefix}    Set Variable If
    ...    '${pod_prefix_default}' == '${EMPTY}'    po-cran1    ${pod_prefix_default}
    SISO Stop Bip Log    alias=${alias_issh}
    FOR    ${cu_index}    IN    @{cu_list}
        ${gnb_index}    Fetch From Right    ${cu_index}    _
        ${namespace}=    Set Variable    ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.namespace}
        Set Test Variable    ${namespace}
        ${remote_log_dir}=     bip_func.download_bip_log_to_master    pod_name=${pod_name}
        ...    namespace=${namespace}
        ...    container_name=${container_name}
        ...    tmp_log_dir=/tmp/bip/
        ...    pod_prefix=${pod_prefix}
        ...    container_prefix=${container_prefix}
        ...    conn=vdu_master
        ...    timeout=${timeout}
        ${bip_local_dir}=    Join Path    ${TEST_LOGS_DIR_PATH}    bip
        ${bip_local_file_path}=    Join Path    ${bip_local_dir}    ${container_name}.pcap
        Set Test Variable    ${bip_local_file_path}
        issh.Download File    remote_path=/tmp/bip/tmp-bip.pcap
        ...    local_path=${bip_local_file_path}    alias=${alias_issh}
        issh.Download File    remote_path=/tmp/bip/start_bip.log
        ...    local_path=${bip_local_dir}/start_bip.log    alias=${alias_issh}
        return from keyword    ${bip_local_file_path}
    END
    [Teardown]    RUN KEYWORDS    run keyword and ignore error    basic_system_operation.master_close    conn=${conn}    AND
    ...    run keyword and ignore error    issh.disconnect    alias=${alias_issh}

#--------------------------------------------SYSLOG------------------------------------------------
SISO Collect Syslog In Cu
    [Arguments]     ${cu_list}=${CU_LIST}    ${timeout}=${10}    ${duration}=300s
    FOR    ${cu_index}    IN    @{cu_list}
        ${gnb_index}    Fetch From Right    ${cu_index}    _
        ${hostname}    Set Variable
        ...    ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
        ${username}    Set Variable
        ...    ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
        ${password}    Set Variable
        ...    ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
        ${namespace}    Set Variable    ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.namespace}
        Log To Console   \n*** Start to collect vcu syslogs to local  ***
        ${alias}=    basic_system_operation.master_connect    hostname=${hostname}    username=${username}
        ...    password=${password}    alias=master
        Set Test Variable    ${alias}
        ${syslog_log_path}=    basic_system_operation.create_a_directory    log_path=${TEST_LOGS_DIR_PATH}
        ...    directory_name=syslog    cu_vdu_index=${cu_index}
        ${syslog_name}=    Set Variable    ${cu_index}_syslog.txt
        ${syslog_local_file_path}     k8s_func.collect_sys_log    namespace=${namespace}
        ...    tmp_log_dir=${syslog_log_path}
        ...    syslog_name=${syslog_name}
        ...    conn=${alias}
        ...    timeout=${timeout}
        ...    duration=${duration}
        Set Test Variable    ${syslog_local_file_path}
        Log To Console   \n*** Vcu syslogs collected to local..${syslog_local_file_path}  ***
        Return From Keyword    ${syslog_local_file_path}
    END
    [Teardown]    Run Keyword And Ignore Error    basic_system_operation.master_close    alias=${alias}

SISO Collect Syslog In vDu
    [Arguments]    ${vdu_list}=${VDU_LIST}    ${timeout}=${10}    ${duration}=300s
    FOR    ${vdu}    IN    @{vdu_list}
        ${cu_index}    ${vdu_index}    Split String    ${vdu}    -
        ${gnb_index}    Fetch From Right    ${cu_index}    _
        ${vdu_index}    Fetch From Right    ${vdu_index}    _
        ${vdu_k8s_master_ssh_connection_info}    Get K8s Master SSH Connection Info In vDU    gnb_index=${gnb_index}
        ...    vdu_index=${vdu_index}
        ${ip}    Set Variable    ${vdu_k8s_master_ssh_connection_info["addr"]}
        ${username}    Set Variable    ${vdu_k8s_master_ssh_connection_info["username"]}
        ${password}    Set Variable    ${vdu_k8s_master_ssh_connection_info["password"]}
        ${namespace}=    Set Variable    ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.namespace}
        Log To Console   \n*** Start to collect vdu syslogs to local  ***
        ${alias}=    basic_system_operation.master_connect    hostname=${ip}
        ...    username=${username}
        ...    password=${password}
        ...    alias=master
        Set Test Variable    ${alias}
        ${syslog_log_path}=    basic_system_operation.create_a_directory    log_path=${TEST_LOGS_DIR_PATH}
        ...    directory_name=syslog    cu_vdu_index=${vdu}
        ${syslog_name}=    Set Variable    ${vdu}_syslog.txt
        ${syslog_local_file_path}     k8s_func.collect_sys_log    namespace=${namespace}
        ...    tmp_log_dir=${syslog_log_path}
        ...    syslog_name=${syslog_name}
        ...    conn=${alias}
        ...    timeout=${timeout}
        ...    duration=${duration}
        Set Test Variable    ${syslog_local_file_path}
        Log To Console   \n*** Vdu syslogs collected to local..${syslog_local_file_path}  ***
        Return From keyword    ${syslog_local_file_path}
    END
    [Teardown]    Run Keyword And Ignore Error    basic_system_operation.master_close    alias=${alias}

SISO Remove Syslog In Cu
    [Arguments]    ${cu_list}=${CU_LIST}    ${timeout}=${10}    ${duration}=60s
    Log To Console   \n*** Start to clear vcu syslogs...  ***
    FOR    ${cu_index}    IN    @{cu_list}
        ${gnb_index}    Fetch From Right    ${cu_index}    _
        ${hostname}    Set Variable
        ...    ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
        ${username}    Set Variable
        ...    ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
        ${password}    Set Variable
        ...    ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
        ${namespace}    Set Variable    ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.namespace}
        ${alias}=    basic_system_operation.master_connect    hostname=${hostname}
        ...    username=${username}
        ...    password=${password}
        ...    alias=master
        Set Test Variable    ${conn}
        k8s_func.remove_sys_log    namespace=${namespace}
        ...    conn=${alias}
        ...    timeout=${timeout}
        ...    duration=${duration}
    END
    [Teardown]    Run Keyword And Ignore Error    basic_system_operation.master_close    alias=${alias}

SISO Remove Syslog In Du
    [Arguments]    ${vdu_list}=${VDU_LIST}    ${timeout}=${10}
    ...    ${duration}=300s
    FOR    ${vdu}    IN    @{vdu_list}
        ${cu_index}    ${vdu_index}    Split String    ${vdu}    -
        ${gnb_index}    Fetch From Right    ${cu_index}    _
        ${vdu_index}    Fetch From Right    ${vdu_index}    _
        ${vdu_k8s_master_ssh_connection_info}    Get K8s Master SSH Connection Info In vDU    gnb_index=${gnb_index}
        ...    vdu_index=${vdu_index}
        ${ip}    Set Variable    ${vdu_k8s_master_ssh_connection_info["addr"]}
        ${username}    Set Variable    ${vdu_k8s_master_ssh_connection_info["username"]}
        ${password}    Set Variable    ${vdu_k8s_master_ssh_connection_info["password"]}
        ${namespace}=    Set Variable    ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.namespace}
        Log To Console   \n*** Start to clear vdu syslogs...  ***
        ${alias}=    basic_system_operation.master_connect    hostname=${ip}
        ...    username=${username}
        ...    password=${password}
        ...    alias=master
        Set Test Variable    ${alias}
        k8s_func.remove_sys_log    namespace=${namespace}
        ...    conn=${conn}
        ...    timeout=${timeout}
        ...    duration=${duration}
    [Teardown]    Run Keyword And Ignore Error    basic_system_operation.master_close    alias=${alias}

#--------------------------------------------Wireshark------------------------------------------------
SISO Start Wireshark Log In vDU
    [Arguments]    ${cu_list}=${CU_LIST}    ${container_name}=${EMPTY}    ${pod_name}=${EMPTY}
    ...            ${timeout}=${10}    ${protocol}=${EMPTY}    ${interface}=any
    ${container_name}    Set Variable If    '${container_name}' == '${EMPTY}'    nwmgmt    ${container_name}
    ${pod_name}    Set Variable If    '${pod_name}' == '${EMPTY}'    cprt    ${pod_name}
    ${protocol}    Set Variable If    '${protocol}' == '${EMPTY}'    sctp    ${protocol}
    FOR    ${cu_index}    IN    @{CU_LIST}
        ${gnb_index}    Fetch From Right    ${cu_index}    _
        ${hostname}    Set Variable
        ...    ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
        ${username}    Set Variable
        ...    ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
        ${password}    Set Variable
        ...    ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
        ${namespace}=    Set Variable    ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.namespace}
        ${alias}=    basic_system_operation.master_connect    hostname=${hostname}    username=${username}
        ...    password=${password}    alias=vdu_master
        Set Test Variable    ${alias}
        wireshark_func.start_wireshark_log    pod_name=${pod_name}    namespace=${namespace}
        ...    container_name=${container_name}    conn=${alias}    timeout=${timeout}    protocol=${protocol}
        ...    interface=${interface}
    END
    [Teardown]    Run keyword and ignore error    SISO Stop Wireshark Log And Download To K8s Master In vDU
    ...    cu_list=${CU_LIST}    container_name=${container_name}    pod_name=${pod_name}    timeout=${10}
    ...    log_name=wireshark    alias=${alias}

SISO Start Wireshark Log In vCU
    [Arguments]    ${cu_list}=${CU_LIST}    ${container_name}=${EMPTY}    ${pod_name}=${EMPTY}
    ...            ${timeout}=${10}    ${protocol}=${EMPTY}    ${interface}=any
    ${container_name}    Set Variable If    '${container_name}' == '${EMPTY}'    nwmgmt    ${container_name}
    ${pod_name}    Set Variable If    '${pod_name}' == '${EMPTY}'    cpif    ${pod_name}
    ${protocol}    Set Variable If    '${protocol}' == '${EMPTY}'    sctp    ${protocol}
    FOR    ${cu_index}    IN    @{CU_LIST}
        ${gnb_index}    Fetch From Right    ${cu_index}    _
        ${hostname}    Set Variable
        ...    ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
        ${username}    Set Variable
        ...    ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
        ${password}    Set Variable
        ...    ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
        ${namespace}=    Set Variable    ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.namespace}
        ${alias}=    basic_system_operation.master_connect    hostname=${hostname}    username=${username}
        ...    password=${password}    alias=vcu_master
        Set Test Variable    ${conn}
        wireshark_func.start_wireshark_log    pod_name=${pod_name}    namespace=${namespace}
        ...    container_name=${container_name}    conn=${alias}    protocol=${protocol}    interface=${interface}
        ...    timeout=${timeout}
    END
    [Teardown]    Run keyword and ignore error    SISO Stop Wireshark Log And Download To K8s Master With gzip In vCU
    ...    cu_list=${CU_LIST}    container_name=${container_name}    alias=${alias}
    ...    pod_name=${pod_name}    timeout=${10}    log_name=wireshark

SISO Stop Wireshark Log And Download To K8s Master In vDU
    [Arguments]    ${cu_list}=${CU_LIST}    ${container_name}=${EMPTY}    ${pod_name}=${EMPTY}    ${timeout}=${10}
    ...    ${log_name}=wireshark    ${alias}=vdu_master
    ${container_name}    Set Variable If    '${container_name}' == '${EMPTY}'    nwmgmt    ${container_name}
    ${pod_name}    Set Variable If    '${pod_name}' == '${EMPTY}'    cprt    ${pod_name}
    FOR    ${cu_index}    IN    @{CU_LIST}
        ${gnb_index}    Fetch From Right    ${cu_index}    _
        ${hostname}    Set Variable
        ...    ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
        ${username}    Set Variable
        ...    ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
        ${password}    Set Variable
        ...    ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
        ${namespace}=    Set Variable    ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.namespace}
        ${conn}=    basic_system_operation.master_connect    hostname=${hostname}    username=${username}
        ...    password=${password}    alias=${alias}
        Set Test Variable    ${conn}
        wireshark_func.stop_wireshark    pod_name=${pod_name}    namespace=${namespace}
        ...    container_name=${container_name}    conn=${alias}    timeout=${timeout}
        ${remote_log_dir}=     wireshark_func.download_wireshark_log_to_master_with_gzip    pod_name=${pod_name}
        ...    namespace=${namespace}    container_name=${container_name}    tmp_log_dir=/tmp/    conn=${conn}
        ...    timeout=${timeout}
        ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
        ${local_file_path}=    basic_system_operation.create_a_file    ${TEST_LOGS_DIR_PATH}/${cu_index}_vDU-Wireshark
        ...    ${hostname}_${namespace}_${timestamp}.pcap
        Set Test Variable    ${local_file_path}
        tafssh.Download File    remote_path=${remote_log_dir}    local_path=${local_file_path}    connection=${alias}
        Return From Keyword    ${local_file_path}
    END
    Log     ${log_name}
    [Teardown]    RUN KEYWORDS    run keyword and ignore error    basic_system_operation.master_close    alias=${alias}
    ...    AND    run keyword and ignore error    issh.disconnect    alias=${alias}

SISO Stop Wireshark Log And Download To K8s Master With gzip In vCU
    [Arguments]    ${cu_list}=${CU_LIST}    ${container_name}=${EMPTY}    ${alias}=vcu_master
    ...    ${pod_name}=${EMPTY}    ${timeout}=${10}    ${log_name}=wireshark
    ${container_name}    Set Variable If    '${container_name}' == '${EMPTY}'    nwmgmt    ${container_name}
    ${pod_name}    Set Variable If    '${pod_name}' == '${EMPTY}'    cpif    ${pod_name}
    FOR    ${cu_index}    IN    @{CU_LIST}
        ${gnb_index}    Fetch From Right    ${cu_index}    _
        ${hostname}    Set Variable
        ...    ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
        ${username}    Set Variable
        ...    ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
        ${password}    Set Variable
        ...    ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
        ${namespace}=    Set Variable    ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.namespace}
        ${conn}=    basic_system_operation.master_connect    hostname=${hostname}    username=${username}
        ...    password=${password}    alias=${alias}
        Set Test Variable    ${conn}
        wireshark_func.stop_wireshark    pod_name=${pod_name}    namespace=${namespace}
        ...    container_name=${container_name}    conn=${conn}    timeout=${timeout}
        ${remote_log_dir}=     wireshark_func.download_wireshark_log_to_master_with_gzip    pod_name=${pod_name}
        ...    namespace=${namespace}    container_name=${container_name}    tmp_log_dir=/tmp/    conn=${conn}
        ...    timeout=${timeout}
        ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
        ${local_file_path}=    basic_system_operation.create_a_file    ${TEST_LOGS_DIR_PATH}/${cu_index}_Wireshark
        ...    ${hostname}_${namespace}_${timestamp}.pcap
        Set Test Variable    ${local_file_path}
        tafssh.Download File    remote_path=${remote_log_dir}    local_path=${local_file_path}    connection=${alias}
        Return From keyword    ${local_file_path}
    END
    log    ${log_name}
    [Teardown]    RUN KEYWORDS    run keyword and ignore error    basic_system_operation.master_close    alias=${alias}
    ...    AND    run keyword and ignore error    issh.disconnect    alias=${alias}

#--------------------------------------------TTI------------------------------------------------
SISO Start TTI Log In vDU
    [Arguments]    ${vdu_list}=${VDU_LIST}    ${host}=10.56.221.45    ${port}=443    ${username}=dcapuser
    ...    ${password}=dcapadmin!    ${rd_version}=dcapv3    ${secure}=${True}    ${alias}=dcap
    FOR    ${vdu}    IN    @{vdu_list}
        ${cu_index}    ${vdu_index}    Split String    ${vdu}    -
        ${gnb_index}    Fetch From Right    ${cu_index}    _
        ${vdu_index}    Fetch From Right    ${vdu_index}    _``
        ${oam_httpaddr}    set variable
        ...    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
        ${vdu_web_ip}    set variable if    ':' in '''${oam_httpaddr}'''    [${oam_httpaddr}]    ${oam_httpaddr}
        &{vdu_info}=    create dictionary    host=${vdu_web_ip}    port=${port}    username=Nemuadmin
        ...    password=Nokia@123
        log to console    \nStarting to connect to the DCAP server
        SISO Connect To DCAP    host=${host}    port=${port}    username=${username}    password=${password}
        ...    rd_version=${rd_version}    secure=${secure}    alias=${alias}
        log to console    \nstarting trace
        ${trace_id}    SISO Start Trace In DCAP    ${vdu_info}    tag=start_trace
        ...    vdu_custom_profile=None
        ...    force=${True}    vcu_trace_profile=None
        ...    vdu_trace_profile=None    enb_trace_profile=None
        ...    bts_trace_profile=None    wait_for_activation=${False}
        ...    timeout=${400}
        Sleep    120S    reason=Waiting For TTI capture
        ${tti_csv_file_paths}=    SISO Stop And Decode TTI Log In vDU    ${vdu_web_ip}
        Return From Keyword    ${vdu_web_ip}    ${trace_id}    ${tti_csv_file_paths}
    END

SISO Connect To DCAP
    [Arguments]    ${host}=10.56.221.45     ${port}=443    ${username}=dcapuser    ${password}=dcapadmin!
    ...    ${rd_version}=dcapv3    ${secure}=${True}    ${alias}=dcap
    dcap_func.connect_to_dcap    ${host}    ${port}    username=${username}    password=${password}
    ...    rd_version=${rd_version}    secure=${secure}    alias=${alias}

SISO Start Trace In DCAP
    [Arguments]    ${bts_dic}    ${tag}=start_trace    ${force}=${True}
    ...    ${gnb_trace_profile}=dcap-lite-default
    ...    ${vcu_trace_profile}=None
    ...    ${vdu_trace_profile}=None
    ...    ${enb_trace_profile}=None
    ...    ${bts_trace_profile}=None
    ...    ${custom_filter_file}=None
    ...    ${gnb_custom_profile_list}=None
    ...    ${enb_custom_profile_list}=None
    ...    ${vdu_custom_profile}=None
    ...    ${vcu_custom_profile}=None
    ...    ${wait_for_activation}=${False}
    ...    ${timeout}=${400}
    ${trace_info}    dcap_func.start_trace_in_dcap    ${bts_dic}    tag=${tag}    force=${force}
    ...    gnb_trace_profile=${gnb_trace_profile}
    ...    vcu_trace_profile=${vcu_trace_profile}
    ...    vdu_trace_profile=${vdu_trace_profile}
    ...    enb_trace_profile=${enb_trace_profile}
    ...    bts_trace_profile=${bts_trace_profile}
    ...    custom_filter_file=${custom_filter_file}
    ...    gnb_custom_profile_list=${gnb_custom_profile_list}
    ...    enb_custom_profile_list=${enb_custom_profile_list}
    ...    vdu_custom_profile=${vdu_custom_profile}
    ...    vcu_custom_profile=${vcu_custom_profile}
    ...    wait_for_activation=${wait_for_activation}
    ...    timeout=${timeout}
    [Return]    ${trace_info}[id]

SISO Stop TTI Log In vDU
    [Arguments]    ${vdu_web_ip}
    [Timeout]    20 min
    log to console    \nstopping trace
    SISO Stop Trace In DCAP    ${vdu_web_ip}
    log to console    \nDownloading logs
    ${dcap_local_file_path}    SISO Download Trace File    ${vdu_web_ip}
    [Return]    ${dcap_local_file_path}

SISO Stop And Decode TTI Log In vDU
    [Arguments]    ${vdu_web_ip}    ${is_combine_dl_ul}=${True}
    ${dcap_local_file_path}    SISO Stop TTI Log In vDU    ${vdu_web_ip}
    @{files}    List Files In Directory    ${dcap_local_file_path}    *.zip
    ${tti_archive}    set variable    ${dcap_local_file_path}/@{files}[0]
    basic_system_operation.vm_connect    ${PC_HOST}    ${PC_USER}    ${PC_PASSWORD}    alias=VM
    collect_tti_log_func.download_decode_tool    ${ENB_BUILD}    ${dcap_local_file_path}    VM
    ${tti_csv_file_paths}    collect_tti_log_func.decode_tti_tool
    ...    ${ENB_BUILD}    ${dcap_local_file_path}    ${tti_archive}
    ...    ${is_combine_dl_ul}    VM
    [Return]    ${tti_csv_file_paths}
    [Teardown]    Run Keyword And Ignore Error    basic_system_operation.vm_close    alias=VM

SISO Stop Trace In DCAP
    [Arguments]    ${btsip}
    dcap_func.stop_trace_in_dcap    ${btsip}

SISO Download Trace File
    [Arguments]    ${btsip}    ${wait_time}=300s
    ...            ${timeout}=${600}
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${dcap_local_file_path}    Join path    ${TEST_LOGS_DIR_PATH}    DCAP    ${timestamp}
    Create directory    ${dcap_local_file_path}
    Set Test Variable    ${dcap_local_file_path}
    ${last_trace_id}    dcap_func.get_last_trace_id    ${btsip}
    Wait Until Keyword Succeeds    ${wait_time}    10s
    ...    SISO Make Sure Trace Status Ready    ${last_trace_id}
    dcap_func.download_trace_file    ${btsip}    target_dir=${dcap_local_file_path}    timeout=${timeout}
    [Return]    ${dcap_local_file_path}

SISO Make Sure Trace Status Ready
    [Arguments]    ${trace_id}
    ${trace_status}    dcap_func.check_trace_status    ${trace_id}
    Should Be True    ${trace_status}
