*** Settings ***
Documentation
...    Author: Liu, Renhui
...    Contact: renhui-david.liu@nokia-sbell.com

Resource          common/product_config_reader.robot
Resource          common/cloud_bts.robot
Resource          common_log_worker.robot
Resource          common/issh_connect.robot
Library           common/ssh_connect.py                 WITH NAME    ssh_connector
Library           common/cloud_wireshark.py             WITH NAME    cloud_wireshark
Library           common/cloud_k8s.py                   WITH NAME    cloud_k8s
Library           common/cloud_bip.py                   WITH NAME    cloud_bip
Library           common/common_utils.py                WITH NAME    utility
Library           common/log_metadata.py                WITH NAME    metadata
Library           taf.gnb.oam.coam.cu.interface.cu      WITH NAME    cloud_vcu
Library           taf.gnb.oam.coam.vdu.interface.Vdu    WITH NAME    cloud_vdu





*** Keywords ***
#---------------------wireshark--------------------------------------------------------------------------
cloud_worker.Start To Collect Wireshark Log
    [Arguments]    ${product_type}=vdu
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${pod_name}=cprt
    ...            ${container_name}=nwmgmt
    ...            ${protocol}=sctp
    ...            ${wireshark_interface}=any
    ...            ${connection}=${None}
    ...            ${timeout}=${300}
    ...            &{template_params}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is for general use. It can capture wireshark Logs from different BTS products.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | product_type | Yes | vdu, vcu, classical |
    ...    | bts_index | Yes | The list index from tl.cu[]  |
    ...    | cudu_index | Yes | the index of cu, du or classical bts  |
    ...    | connection | Yes | an alias for reusing an existing connection later |
    ...    | timeout | No | timeout |
    ...    *Example:*
    ...        - cloud_worker.Start To Collect Wireshark Log
    ...
    ${ssh_connection_params}=    product_config.Get BTS SSH Connection Info    product_type=${product_type}
    ...    bts_index=${bts_index}    cudu_index=${cudu_index}
    ssh_connector.connect_to_server    ${connection}    &{ssh_connection_params}
    ${namespace}=        product_config.Get BTS Namespace
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    cudu_index=${cudu_index}
    cloud_wireshark.start_wireshark_log    ${connection}
    ...    namespace=${namespace}
    ...    pod_name=${pod_name}
    ...    container_name=${container_name}
    ...    protocol=${protocol}
    ...    interface=${wireshark_interface}
    ...    timeout=${timeout}

cloud_worker.Stop and Download Wireshark Log
    [Arguments]    ${product_type}=vdu
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${pod_name}=cprt
    ...            ${container_name}=nwmgmt
    ...            ${connection}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is for general use. It stops and downloads wireshark Logs from different BTS products.
    ...        - Supported BTS products: vdu, vcu
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | product_type | Yes | vdu, vcu, classical |
    ...    | bts_index | Yes | The list index from tl.cu[]  |
    ...    | cudu_index | Yes | the index of cu, du or classical bts  |
    ...    | connection | Yes | an alias for reusing an existing connection later |
    ...    | timeout | No | timeout |
    ...    *Example:*
    ...        - cloud_worker.Stop and Download Wireshark Log
    ...
    ${ssh_connection_params}=    product_config.Get BTS SSH Connection Info    product_type=${product_type}
    ...    bts_index=${bts_index}    cudu_index=${cudu_index}
    ${namespace}=        product_config.Get BTS Namespace
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    cudu_index=${cudu_index}
    ssh_connector.connect_to_server    ${connection}    &{ssh_connection_params}
    cloud_wireshark.stop_wireshark_log    ${connection}
    ...    namespace=${namespace}
    ...    pod_name=${pod_name}
    ...    container_name=${container_name}
    ...    timeout=${timeout}
    ${copy_way}=    set variable    cat
    ${host_log_path}=     cloud_wireshark.copy_wireshark_log_from_container_to_host    ${connection}
    ...    namespace=${namespace}
    ...    pod_name=${pod_name}
    ...    container_name=${container_name}
    ...    container_log_dir=/tmp/
    ...    host_log_dir=/tmp/
    ...    copy_way=${copy_way}
    ...    timeout=${timeout}
    ${log_dir_by_level}=    _CommonBTS.Get Log Directory For Log Module By Level
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${local_file_path}=    utility.create_local_file    ${log_dir_by_level}/${product_type}-Wireshark
    ...    ${ssh_connection_params.hostname}_${namespace}_${timestamp}.pcap
    ssh_connector.Download File    ${connection}    remote_path=${host_log_path}    local_path=${local_file_path}
    [Return]    ${local_file_path}
    [Teardown]    run keyword and ignore error    ssh_connector.disconnect from server    ${connection}


#---------------------bip--------------------------------------------------------------------------
cloud_worker.Start To Collect Bip Log
    [Arguments]    ${product_type}=vdu
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${pod_name}=l2rt
    ...            ${container_name}=l2rt
    ...            ${port_name}=l1up
    ...            ${connection}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to collect Bip Logs.
    ...        - Supported BTS products: vdu
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | product_type | Yes | vdu, vcu, classical |
    ...    | bts_index | Yes | The list index from tl.cu[]  |
    ...    | cudu_index | Yes | the index of cu, du or classical bts  |
    ...    | connection | Yes | an alias for reusing an existing connection later |
    ...    | timeout | No | timeout |
    ...    *Example:*
    ...        - cloud_worker.Start To Collect Bip Log
    ...
    Log To Console    ${timeout}
    issh_connector.Connect To CloudRan Host    ${connection}
    ...            product_type=${product_type}
    ...            bts_index=${bts_index}
    ...            cudu_index=${cudu_index}
    ${namespace}=        product_config.Get BTS Namespace
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    cudu_index=${cudu_index}

    ${ssh_connection_params}=    product_config.Get BTS SSH Connection Info    product_type=${product_type}
    ...    bts_index=${bts_index}    cudu_index=${cudu_index}
    ssh_connector.connect_to_server    ${connection}    &{ssh_connection_params}
    ${pod_prefix}=    cloud_k8s.get_pod_name_prefix    ${connection}    ${namespace}
    ${bip_pod}=    cloud_k8s.get_log_service_pod_name    ${connection}    ${namespace}    pod_type=l2rt
    ${split_pod}    Evaluate    '${bip_pod}'.split('-')
    ${pod_name}    Set Variable If    'a' in ${split_pod}    l2rt-a    l2rt
    ${container_log_path}=    set variable    /tmp/dpdkdump/*.pcap
    _REMOVE LOG IN CONTAINER    ${connection}    ${namespace}    ${pod_prefix}    ${pod_name}    ${container_name}
    ...    ${container_log_path}

    ${log_capture_tool}=    Set Variable     hal-cli
#    ${bip_pod}    set variable    ${pod_prefix}${namespace}-${pod_name}-0
    ${bip_container}    set variable    ctr-${namespace}-${container_name}
    ${port_getting_cmd}=    Catenate  kubectl exec -it ${bip_pod} -c ${bip_container} -n ${namespace}
    ...     -- bash -c "${log_capture_tool} show port table | grep ${port_name}"
    ${port_id}=    _Get Bip Port ID    ${connection}    ${port_getting_cmd}
    ${bip_cmd}=    Catenate  kubectl exec -it  ${bip_pod} -n ${namespace}
    ...     -c ${bip_container} -- bash
    ...     -c '${log_capture_tool} pdump port ${port_id} path /tmp/dpdkdump > /tmp/dpdkdump/start_bip.log 2>&1'
    issh.Execute_bare    command=${bip_cmd}    alias=${connection}
    issh_connector.Send ENTER Interactively    connection=${connection}

cloud_worker.Stop and Download Bip Log
    [Arguments]    ${product_type}=vdu
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${pod_name}=l2rt
    ...            ${container_name}=l2rt
    ...            ${connection}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to stop and download Bip Log.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | product_type | Yes | vdu, vcu, classical |
    ...    | bts_index | Yes | The list index from tl.cu[]  |
    ...    | cudu_index | Yes | the index of cu, du or classical bts  |
    ...    | connection | Yes | an alias for reusing an existing connection later |
    ...    | timeout | No | timeout |
    ...    *Example:*
    ...        - cloud_worker.Stop and Download Bip Log
    ...
    cloud_worker.Stop Bip Log    ${connection}

    ${namespace}=    product_config.Get BTS Namespace
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    cudu_index=${cudu_index}
    ${bip_pod}=    cloud_k8s.get_log_service_pod_name    ${connection}    ${namespace}    pod_type=l2rt
    ${split_pod}    Evaluate    '${bip_pod}'.split('-')
    ${pod_name}    Set Variable If    'a' in ${split_pod}    l2rt-a    l2rt
    cloud_bip.copy_bip_log_from_container_to_host    ${connection}    ${namespace}    ${pod_name}    ${container_name}
    ...    timeout=${timeout}

    ${log_dir_by_level}=    _CommonBTS.Get Log Directory For Log Module By Level
    ${bip_local_dir}=    Join Path    ${log_dir_by_level}    bip
    ${bip_local_file_path}=    Join Path    ${bip_local_dir}    ${container_name}.pcap
    issh.Download File    remote_path=/tmp/bip/tmp-bip.pcap
    ...    local_path=${bip_local_file_path}    alias=${connection}
    issh.Download File    remote_path=/tmp/bip/start_bip.log
    ...    local_path=${bip_local_dir}/start_bip.log    alias=${connection}
    [Return]    ${bip_local_file_path}
    [Teardown]    RUN KEYWORDS    run keyword and ignore error    ssh_connector.disconnect from server    ${connection}
    ...    AND                    run keyword and ignore error    issh.disconnect    alias=${connection}

cloud_worker.Stop Bip Log
    [Arguments]    ${connection}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to stop bip log.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | connection | Yes | an alias for reusing an existing connection later |
    ...    *Example:*
    ...        - cloud_worker.Stop Bip Log
    ...
    ${output}   issh_connector.Send CTRL_C Interactively     ${connection}
    [Return]  ${output}

cloud_worker.Start To Collect Syslog Log
    [Arguments]    ${product_type}=vdu
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${connection}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to collect syslog from vdu or vcu.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | product_type | Yes | vdu, vcu |
    ...    | bts_index | Yes | The list index from tl.cu[]  |
    ...    | cudu_index | Yes | the index of cu, du or classical bts  |
    ...    | connection | Yes | an alias for reusing an existing connection later |
    ...    | timeout | No | timeout |
    ...    *Example:*
    ...        - cloud_worker.Start To Collect Syslog Log
    ...
    ${ssh_connection_params}=    product_config.Get BTS SSH Connection Info    product_type=${product_type}
    ...    bts_index=${bts_index}    cudu_index=${cudu_index}
    ssh_connector.connect_to_server    ${connection}    &{ssh_connection_params}
    ${namespace}=        product_config.Get BTS Namespace
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    cudu_index=${cudu_index}
    ${host_log_path}=    cloud_k8s.start_syslog_log    ${connection}
    ...    ${namespace}
    ...    host_log_dir=/tmp/
    ...    timeout=${timeout}

    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${log_dir_by_level}=    _CommonBTS.Get Log Directory For Log Module By Level
    ${local_file_path}=    utility.create_local_file    ${log_dir_by_level}/${product_type}-syslog
    ...    ${ssh_connection_params.hostname}_${namespace}_${timestamp}.syslog.txt.zip
    ssh_connector.Download File    ${connection}    remote_path=${host_log_path}    local_path=${local_file_path}
    ssh_connector.remove_file    ${connection}    remote_path=${host_log_path}
    [Return]    ${local_file_path}
    [Teardown]    run keyword and ignore error    ssh_connector.disconnect from server    ${connection}

cloud_worker.Start To Collect vcu Snapshot Log
    [Arguments]    ${product_type}=vcu
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${connection}=${None}
    ...            ${timeout}=${1200}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to collect Snapshot from vcu.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | product_type | Yes | vdu, vcu |
    ...    | bts_index | Yes | The list index from tl.cu[]  |
    ...    | cudu_index | Yes | the index of cu, du or classical bts  |
    ...    | connection | Yes | an alias for reusing an existing connection later  |
    ...    | timeout | No | timeout |
    ...    *Example:*
    ...        - cloud_worker.Start To Collect vcu Snapshot Log
    ...
    ${log_dir_by_level}=    _CommonBTS.Get Log Directory For Log Module By Level
    ${snapshot_dir}=    set variable    ${log_dir_by_level}/vcu_snapshot
    utility.create_local_directory    ${snapshot_dir}

    ${bts_http_con_info}=    product_config.Get BTS Http Connection Info    product_type=${product_type}
    ...    bts_index=${bts_index}    cudu_index=${cudu_index}
    cloud_bts.Connect To vCU By Rest    ${connection}
    ...    &{bts_http_con_info}    timeout=${timeout}

    ${status}=    cloud_vcu.check_snapshot_status    connection=${connection}
    ${Snapshot_path}=    Run Keyword If    '${status}'=='idle'
    ...        cloud_vcu.Get_Local_Snapshot    ${snapshot_dir}    use_m2m=${True}    connection=${connection}
    ...    ELSE IF    '${status}'=='local-ongoing'
    ...        _Wait vCU Snapshot Status To Idle And Get Latest Snapshot    ${connection}    ${snapshot_dir}
    [Return]    ${Snapshot_path}
    [Teardown]    Run Keyword And Ignore Error    cloud_bts.Disconnect From vCU    ${connection}

cloud_worker.Start To Collect vdu Snapshot Log
    [Arguments]    ${product_type}=vdu
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${connection}=${None}
    ...            ${timeout}=${1200}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to collect Snapshot from vdu.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | product_type | Yes | vdu, vcu |
    ...    | bts_index | Yes | The list index from tl.cu[]  |
    ...    | cudu_index | Yes | the index of cu, du or classical bts  |
    ...    | connection | Yes | an alias for reusing an existing connection later  |
    ...    | timeout | No | timeout |
    ...    *Example:*
    ...        - cloud_worker.Start To Collect vcu Snapshot Log
    ...
    ${log_dir_by_level}=    _CommonBTS.Get Log Directory For Log Module By Level
    ${snapshot_dir}=    set variable    ${log_dir_by_level}/vdu_snapshot
    utility.create_local_directory    ${snapshot_dir}

    ${bts_http_con_info}=    product_config.Get BTS Http Connection Info    product_type=${product_type}
    ...    bts_index=${bts_index}    cudu_index=${cudu_index}
    cloud_bts.Connect To vDU By Rest    ${connection}
    ...    &{bts_http_con_info}    timeout=${timeout}

    ${status}=    cloud_vdu.check_snapshot_status    vdu_connection=${connection}
    log to console    \nStarting to collect vdu snapshot
    ${Snapshot_path}=    Run Keyword If    '${status}'=='idle'
    ...                 cloud_vdu.Get_Local_Snapshot    directory=${snapshot_dir}    use_m2m=${True}
    ...                        vdu_connection=${connection}    filter_regx=${None}    compressed_or_not=${True}
    ...    ELSE IF    '${status}'=='local-ongoing'
    ...                 _Wait vDU Snapshot Status To Idle And Get Latest Snapshot    ${connection}    ${snapshot_dir}
    [Return]    ${Snapshot_path}
    [Teardown]    Run Keyword And Ignore Error    cloud_bts.Disconnect From vDU    ${connection}

################################ Manage connection name #################################
cloud_worker.get_connection_name
    [Arguments]    ${log_type}
    ...            ${product_type}=vdu
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to get an connection name.
    ...        - The name is automatically generated according to convention.
    ...        - The advantage of this is to free the end users from managing aliases everywhere.
    ...        - The convention for name is:
    ...        -     vdu: ${log_type}_vcu${bts_index}_vdu${cudu_index}
    ...        -     vcu: ${log_type}_vcu${bts_index}
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | log_type | Yes | bip, wireshark, tti, syslog, snapshot, etc. |
    ...    | product_type | Yes | vdu, vcu, classical |
    ...    | bts_index | Yes | The list index from tl.cu[]  |
    ...    | cudu_index | Yes | the index of cu, du or classical bts  |
    ...    *Example:*
    ...        - cloud_worker.get_connection_name
    ...
    ${name}=    Run Keyword If    '${product_type}' == 'vdu'
    ...    set variable    ${log_type}_vcu${bts_index}_vdu${cudu_index}
    ...    ELSE IF  '${product_type}' == 'vcu'
    ...    set variable    ${log_type}_vcu${bts_index}
    [Return]    ${name}


#---------------------Supported--------------------------------------------------------------------------
_Wait vCU Snapshot Status To Idle And Get Latest Snapshot
    [Arguments]   ${connection}
    ...           ${snapshot_dir}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to finish local ongoing vCU snapshot, then get latest local snapshot.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | snapshot_dir | Yes | snapshot directory |
    ...    *Example:*
    ...        - _Wait vCU Snapshot Status To Idle And Get Latest Snapshot
    ...
    ${previous_snapshot_dir}=    set variable    ${snapshot_dir}/previous
    ${snapshot_info}    cloud_vcu.get_snapshot_operations_information    connection=${connection}
    FOR    ${info}    IN    @{snapshot_info}
        Run Keyword And Ignore Error    cloud_vcu.get_local_snapshot_by_id    directory=${previous_snapshot_dir}
        ...    operation_id=${info['operation_id']}    operation_timeout=${1200}    connection=${connection}
        Run Keyword And Ignore Error    cloud_vcu.cancel_snapshot_operation
        ...    operation_id=${info['operation_id']}    connection=${connection}
    END
    ${status}=    cloud_vcu.check_snapshot_status    connection=${connection}
    ${Snapshot_path}=    Run Keyword If    '${status}'=='idle'
    ...    cloud_vcu.Get_Local_Snapshot    ${snapshot_dir}    use_m2m=${True}    connection=${connection}
    [Return]    ${Snapshot_path}

_Wait vDU Snapshot Status To Idle And Get Latest Snapshot
    [Arguments]   ${connection}
    ...           ${snapshot_dir}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to finish local ongoing vDU snapshot, then get latest local snapshot.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | snapshot_dir | Yes | snapshot directory |
    ...    *Example:*
    ...        - _Wait vDU Snapshot Status To Idle And Get Latest Snapshot
    ...
    ${previous_snapshot_dir}=    set variable    ${snapshot_dir}/previous
    ${snapshot_info}    cloud_vdu.get_snapshot_operations_information    vdu_connection=${connection}
    FOR    ${info}    IN    @{snapshot_info}
        Run Keyword And Ignore Error    cloud_vdu.check_local_snapshot_status_and_save_it
        ...    directory=${previous_snapshot_dir}    operation_id=${info['operation_id']}
        ...    operation_timeout=${1200}    vdu_connection=${connection}
        ...    compressed_or_not=${True}    use_m2m=${True}
        Run Keyword And Ignore Error    cloud_vdu.cancel_snapshot_operation
        ...    operation_id=${info['operation_id']}    vdu_connection=${connection}
    END
    ${status}=    cloud_vdu.check_snapshot_status    vdu_connection=${connection}
    ${Snapshot_path}=    Run Keyword If    '${status}'=='idle'
    ...    cloud_vdu.Get_Local_Snapshot    ${snapshot_dir}    use_m2m=${True}    vdu_connection=${connection}
    ...      compressed_or_not=${True}
    [Return]    ${Snapshot_path}

_Remove Log In Container
    [Arguments]    ${connection}
    ...            ${namespace}
    ...            ${pod_prefix}
    ...            ${pod_name}
    ...            ${container_name}
    ...            ${container_log_path}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to remove Log in a container.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | connection | Yes | an alias for reusing an existing connection later|
    ...    | namespace | Yes |  |
    ...    | pod_name | Yes |  |
    ...    | container_name | Yes |  |
    ...    | container_log_path | Yes |  |
    ...    *Example:*
    ...        - _Remove Log In Container
    ...
    ${full_pod_name}=    Catenate  ${pod_name}-0
    ${cmd_remove_log}=    Catenate  kubectl exec -i ${pod_prefix}${namespace}-${pod_name}-0
    ...    -c ctr-${namespace}-${container_name} -n ${namespace} -- bash -c 'rm -r ${container_log_path}'
    run keyword and ignore error    issh.Execute    command=${cmd_remove_log}    alias=${connection}

_Get Bip Port ID
    [Arguments]    ${connection}
    ...            ${port_getting_cmd}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to get bip port id.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | connection | Yes | an alias for reusing an existing connection later|
    ...    | port_getting_cmd | Yes | the command to get port id |
    ...    *Example:*
    ...        - _Get Bip Port ID
    ...
    ${bip_port_id_tmp}    issh.Execute    command=${port_getting_cmd}    alias=${connection}
    ${bip_port_id_output}    Get Regexp Matches    ${bip_port_id_tmp}   (\\d).*BIP
    ${bip_port_output}    split_string    ${bip_port_id_output[0]}    ${SPACE}${SPACE}${SPACE}
    ${bip_port_id}    Set Variable    ${bip_port_output}[0]
    ${port_length}    get length   ${bip_port_id}
    ${port_id}=    Get Substring    ${bip_port_id}    ${${port_length}-1}    ${port_length}
    [Return]    ${port_id}

cloud_worker.Get vCU Active Software Version
    [Arguments]    ${product_type}
    ...            ${bts_index}
    ...            ${cudu_index}
    ...            ${connection}
    ...            ${timeout}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to get active software version.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | bts_index | Yes | The list index from tl.cu[]  |
    ...    | cudu_index | Yes | the index of cu, du or classical bts  |
    ...    | connection | Yes | an alias for reusing an existing connection later  |
    ...    | timeout | No |   |
    ...    *Example:*
    ...        - cloud_worker.Get vCU Active Software Version
    ...
    ${bts_http_con_info}=    product_config.Get BTS Http Connection Info    product_type=${product_type}
    ...    bts_index=${bts_index}    cudu_index=${cudu_index}
    cloud_bts.Connect To vCU By Rest    ${connection}    &{bts_http_con_info}    timeout=${timeout}
    ${bts_version}=    cloud_vcu.get_active_software_version    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    cloud_bts.Disconnect From vCU    ${connection}
    [Return]    ${bts_version}

cloud_worker.Get vDU Active Software Version
    [Arguments]    ${product_type}
    ...            ${bts_index}
    ...            ${cudu_index}
    ...            ${connection}
    ...            ${timeout}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to get active software version.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | bts_index | Yes | The list index from tl.cu[]  |
    ...    | cudu_index | Yes | the index of cu, du or classical bts  |
    ...    | connection | Yes | an alias for reusing an existing connection later  |
    ...    | timeout | No |   |
    ...    *Example:*
    ...        - cloud_worker.Get vDU Active Software Version
    ...
    ${bts_http_con_info}=    product_config.Get BTS Http Connection Info    product_type=${product_type}
    ...    bts_index=${bts_index}    cudu_index=${cudu_index}
    cloud_bts.Connect To vDU By Rest    ${connection}    &{bts_http_con_info}    timeout=${timeout}
    ${vdu_data}=    cloud_vdu.get_vdu_state_data    vdu_connection=${connection}
    ${bts_version}    set variable    ${vdu_data['software_version']}
    [Teardown]    Run Keyword And Ignore Error    cloud_bts.Disconnect From vDU    ${connection}
    [Return]    ${bts_version}

cloud_worker.Get BTS Active Software Version
    [Arguments]    ${product_type}
    ...            ${bts_index}
    ...            ${cudu_index}
    ...            ${connection}
    ...            ${timeout}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to get active software version.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | bts_index | Yes | The list index from tl.cu[]  |
    ...    | cudu_index | Yes | the index of cu, du or classical bts  |
    ...    | connection | Yes | an alias for reusing an existing connection later  |
    ...    | timeout | No |   |
    ...    *Example:*
    ...        - cloud_worker.Get BTS Active Software Version
    ...
    ${bts_version}=    Run Keyword If    '${product_type}'=='vdu'
    ...        cloud_worker.Get vDU Active Software Version    ${product_type}    ${bts_index}    ${cudu_index}
    ...            ${connection}    ${timeout}
    ...    ELSE IF    '${product_type}'=='vcu'
    ...        cloud_worker.Get vCU Active Software Version    ${product_type}    ${bts_index}    ${cudu_index}
    ...            ${connection}    ${timeout}
    ${split_bts_version}=    split_string    ${bts_version}    _
    ${bts_version_pro}    split_string    ${split_bts_version}[1]    .
    Run Keyword If    '${bts_version_pro[0]}'=='0' and '${product_type}'=='vdu'
    ...                          Set Test Variable    ${bts_version}    vDUCNF00_${split_bts_version}[1]
    ...               ELSE IF    '${bts_version_pro[0]}'=='0' and '${product_type}'=='vcu'
    ...                          Set Test Variable    ${bts_version}    vCUCNF00_${split_bts_version}[1]
    ...               ELSE       Set Test Variable    ${bts_version}    ${bts_version}
    [Return]    ${bts_version}

cloud_worker.Start To Collect vdu ip_traffic Log
    [Arguments]    ${product_type}=vdu
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${connection}=${None}
    ...            ${timeout}=${300}
    ...            &{kwargs}

    ${bts_http_con_info}=    product_config.Get BTS Http Connection Info    product_type=${product_type}
    ...    bts_index=${bts_index}    cudu_index=${cudu_index}
    cloud_bts.Connect To vDU By Rest    ${connection}
    ...    &{bts_http_con_info}    timeout=${timeout}
    ${DEFAULT_CAPTURE_TYPE}    Set Variable    pod
    ${DEFAULT_MEASUREMENT_POINT}    Set Variable    NE_Terminated
    ${DEFAULT_PLANE_TYPE}    Set Variable    ${None}
    ${DEFAULT_POD_NAMES}    Set Variable    ${None}
    ${is_input_capture_type}    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${kwargs}    capture_type
    ${capture_type}=    Set Variable If
    ...    ${is_input_capture_type}    ${kwargs["capture_type"]}    ${DEFAULT_CAPTURE_TYPE}

    ${is_input_measurement_point}    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${kwargs}    measurement_point
    ${measurement_point}=    Set Variable If
    ...    ${is_input_measurement_point}    ${kwargs["measurement_point"]}    ${DEFAULT_MEASUREMENT_POINT}

    ${is_input_plane_type}    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${kwargs}    plane_type
    ${plane_type}=    Set Variable If
    ...    ${is_input_plane_type}    ${kwargs["plane_type"]}    ${DEFAULT_PLANE_TYPE}

    ${is_input_pod_names}    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${kwargs}    pod_names
    ${pod_names}=    Set Variable If
    ...    ${is_input_pod_names}    ${kwargs["pod_names"]}    ${DEFAULT_POD_NAMES}

    cloud_vdu.start_ip_traffic_capture    capture_type=${capture_type}
    ...    measurement_point=${measurement_point}    plane_type=${plane_type}
    ...    pod_names=${pod_names}    timeout=${timeout}    vdu_connection=${connection}
    Log to console    Start Ip Traffic Capture In vDU
    [Teardown]    Run Keyword And Ignore Error    cloud_bts.Disconnect From vDU    ${connection}


cloud_worker.Stop To Collect vdu ip_traffic Log
    [Arguments]    ${product_type}=vdu
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${connection}=${None}
    ...            ${timeout}=${300}
    ...            &{kwargs}
    ${log_dir_by_level}=    _CommonBTS.Get Log Directory For Log Module By Level
    ${ip_traffic_dir}=    set variable    ${log_dir_by_level}/vdu_ip_traffic
    utility.create_local_directory    ${ip_traffic_dir}

    ${bts_http_con_info}=    product_config.Get BTS Http Connection Info    product_type=${product_type}
    ...    bts_index=${bts_index}    cudu_index=${cudu_index}
    cloud_bts.Connect To vDU By Rest    ${connection}
    ...    &{bts_http_con_info}    timeout=${timeout}
    cloud_vdu.stop_ip_traffic_capture    timeout=${timeout}    vdu_connection=${connection}
    Sleep              30    reason=Wait until ip traffic capture is completed
    vdu.generate_ip_traffic_capture_files    credentials=     timeout=${timeout}    vdu_connection=${connection}
    Sleep              30    reason=Wait until ip traffic files are generated
    ${info}=           cloud_vdu.get_ip_traffic_capture_status    vdu_connection=${connection}
    ${all_pods_status}=    Set Variable        ${info['pod_status']}
    ${length}=             Get Length    ${all_pods_status}
    FOR    ${l}    IN RANGE    ${length}
        ${pod_info}=             Get From List    ${all_pods_status}    ${l}
        ${file_name}=            Get From Dictionary    ${pod_info}    file_name
        ${correct_file_name}=    Set Variable If    "${file_name}"!="None"    ${file_name}
        Exit For Loop If        "${file_name}"!="None"
    END
    ${upload_info}=    cloud_vdu.activated_file_upload_operation    timeout=${timeout}    vdu_connection=${connection}
    Should Be True    "${upload_info['status']}"=="success"
    ${pcap_path}=    cloud_vdu.upload_ip_traffic_capture_file    operation_id=${upload_info['operation_id']}
    ...              file_name=${correct_file_name}    local_path=${ip_traffic_dir}
    ...              timeout=${timeout}    vdu_connection=${connection}
    RETURN         ${pcap_path}
    [Teardown]       Run Keywords    Run Keyword and Ignore Error    cloud_vdu.delete_file_upload_operation
    ...                              operation_id=${upload_info['operation_id']}    vdu_connection=${connection}
    ...    AND       cloud_bts.Disconnect From vDU    ${connection}

###################################################  vcu part ############################################
cloud_worker.Start To Collect vcu ip_traffic Log
    [Arguments]    ${product_type}=vcu
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${connection}=${None}
    ...            ${timeout}=${300}
    ...            &{kwargs}

    ${bts_http_con_info}=    product_config.Get BTS Http Connection Info    product_type=${product_type}
    ...    bts_index=${bts_index}    cudu_index=${cudu_index}
    cloud_bts.Connect To vCU By Rest    ${connection}
    ...    &{bts_http_con_info}    timeout=${timeout}
    ${DEFAULT_CAPTURE_TYPE}    Set Variable    pod
    ${DEFAULT_MEASUREMENT_POINT}    Set Variable    NE_Terminated
    ${DEFAULT_PLANE_TYPE}    Set Variable    ${None}
    ${DEFAULT_POD_NAMES}    Set Variable    ${None}
    ${is_input_capture_type}    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${kwargs}    capture_type
    ${capture_type}=    Set Variable If
    ...    ${is_input_capture_type}    ${kwargs["capture_type"]}    ${DEFAULT_CAPTURE_TYPE}

    ${is_input_measurement_point}    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${kwargs}    measurement_point
    ${measurement_point}=    Set Variable If
    ...    ${is_input_measurement_point}    ${kwargs["measurement_point"]}    ${DEFAULT_MEASUREMENT_POINT}

    ${is_input_plane_type}    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${kwargs}    plane_type
    ${plane_type}=    Set Variable If
    ...    ${is_input_plane_type}    ${kwargs["plane_type"]}    ${DEFAULT_PLANE_TYPE}

    ${is_input_pod_names}    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${kwargs}    pod_names
    ${pod_names}=    Set Variable If
    ...    ${is_input_pod_names}    ${kwargs["pod_names"]}    ${DEFAULT_POD_NAMES}


    cloud_vcu.start_ip_traffic_capture    capture_type=${capture_type}
    ...    measurement_point=${measurement_point}    plane_type=${plane_type}
    ...    pod_names=${pod_names}    timeout=${timeout}    connection=${connection}

    Log to console    Start Ip Traffic Capture In vCU
    [Teardown]    Run Keyword And Ignore Error    cloud_bts.Disconnect From vCU    ${connection}


cloud_worker.Stop To Collect vcu ip_traffic Log
    [Arguments]    ${product_type}=vcu
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${connection}=${None}
    ...            ${timeout}=${300}
    ...            &{kwargs}
    ${log_dir_by_level}=    _CommonBTS.Get Log Directory For Log Module By Level
    ${ip_traffic_dir}=    set variable    ${log_dir_by_level}/vcu_ip_traffic
    utility.create_local_directory    ${ip_traffic_dir}

    ${bts_http_con_info}=    product_config.Get BTS Http Connection Info    product_type=${product_type}
    ...    bts_index=${bts_index}    cudu_index=${cudu_index}
    cloud_bts.Connect To vCU By Rest    ${connection}
    ...    &{bts_http_con_info}    timeout=${timeout}
    cloud_vcu.stop_ip_traffic_capture    timeout=${timeout}    connection=${connection}
    Sleep              30    reason=Wait until ip traffic capture is completed
    cloud_vcu.generate_ip_traffic_capture_files    credentials=     timeout=${timeout}    connection=${connection}
    Sleep              30    reason=Wait until ip traffic files are generated
    ${info}=           cloud_vcu.get_ip_traffic_capture_status    connection=${connection}
    ${all_pods_status}=    Set Variable        ${info['pod_status']}
    ${length}=             Get Length    ${all_pods_status}
    FOR    ${l}    IN RANGE    ${length}
        ${pod_info}=             Get From List    ${all_pods_status}    ${l}
        ${file_name}=            Get From Dictionary    ${pod_info}    file_name
        ${correct_file_name}=    Set Variable If    "${file_name}"!="None"    ${file_name}
        Exit For Loop If        "${file_name}"!="None"
    END
    ${upload_info}=    cloud_vcu.activated_file_upload_operation    timeout=${timeout}    connection=${connection}
    Should Be True    "${upload_info['status']}"=="success"
    ${pcap_path}=    cloud_vcu.upload_ip_traffic_capture_file    operation_id=${upload_info['operation_id']}
    ...              file_name=${correct_file_name}    local_path=${ip_traffic_dir}
    ...              timeout=${timeout}    connection=${connection}
    RETURN         ${pcap_path}
    [Teardown]       Run Keywords    Run Keyword and Ignore Error    vcu.delete_file_upload_operation
    ...                              connection=${connection}
    ...    AND       cloud_bts.Disconnect From vCU    ${connection}

cloud_worker.Start To Collect k8s Log
        [Arguments]    ${product_type}=vdu
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${connection}=${None}
    ...            ${timeout}=${300}
    ...            &{kwargs}

    [Documentation]
    ...    *Author:*
    ...        - liang.xiang@nokia-sbell.com

    ${DEFAULT_POD_NAME}    Set Variable    l2rt
    ${DEFAULT_CONTAINER_NAME}    Set Variable    l2rt
    ${DEFAULT_DURATION}    Set Variable     1h
    ${ssh_connection_params}=    product_config.Get BTS K8S Connection Info    product_type=${product_type}
    ...    bts_index=${bts_index}    cudu_index=${cudu_index}
    ssh_connector.connect_to_server    ${connection}    &{ssh_connection_params}
    ${namespace}=        product_config.Get BTS Namespace
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    cudu_index=${cudu_index}

    ${is_input_pod_name}    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${kwargs}    pod_name
    ${pod_name}=    Set Variable If
    ...    ${is_input_pod_name}    ${kwargs["pod_name"]}    ${DEFAULT_POD_NAME}

    ${is_input_container_name}    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${kwargs}    container_name
    ${container_name}=    Set Variable If
    ...    ${is_input_container_name}    ${kwargs["container_name"]}    ${DEFAULT_CONTAINER_NAME}

    ${is_input_duration}   Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${kwargs}    duration
    ${duration}=    Set Variable If
    ...    ${is_input_duration}    ${kwargs["duration"]}    ${DEFAULT_DURATION}

    ${k8s_log_path}=    cloud_k8s.collect_k8s_log
    ...    pod_name=${pod_name}
    ...    namespace=${namespace}
    ...    container_name=${container_name}
    ...    tmp_log_dir=/tmp/
    ...    conn=${connection}
    ...    timeout=${timeout}
    ...    duration=${duration}

    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${log_dir_by_level}=    _CommonBTS.Get Log Directory For Log Module By Level
    ${local_file_path}=    utility.create_local_file    ${log_dir_by_level}/${product_type}-k8s
    ...    ${ssh_connection_params.hostname}_${namespace}_${timestamp}_journal.log
    ssh_connector.Download File    ${connection}    remote_path=${k8s_log_path}    local_path=${local_file_path}
    ssh_connector.remove_file    ${connection}    remote_path=${k8s_log_path}
    RETURN    ${local_file_path}
    [Teardown]    run keyword and ignore error    ssh_connector.disconnect from server    ${connection}
