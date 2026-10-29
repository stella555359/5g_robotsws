*** Settings ***
Documentation
...   These are common keywords for logs capturing with tcpdump command, logs stop capturing and logs download.
...   Author: Liu Zheng
...   Contact: zheng.4.liu@nokia-sbell.com
...   Squad:  HZ SG4

Library    OperatingSystem
Library    taf.transport.ssh    WITH NAME    csn
Library    taf.collectors.core          WITH NAME    core
Library    taf.collectors.btslog        WITH NAME    btslog
Library    taf.collectors.tcpdump       WITH NAME    tcpdump
Library    taf.analyzer.pcap    WITH NAME    cap
Resource   taf/rfrl/common_resources/robot/stream_manager.robot
Resource   taf/rfrl/common_resources/robot/connection_alias_store.robot

*** Variables ***
${ABIL_MASTER_ALIAS}    ABIL Master
${ASIK_MASTER_ALIAS}    ASIK Master
${airscale_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${airscale_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${airscale_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${loner_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[0].addr}

*** Keywords ***
Start trace capturing without duration on container
    [Timeout]    20 sec
    [Documentation]    Author: Liu Zheng
    ...                This method is try to start trace capturing with tcpdump command.
    ...                e.g. start the CP-RT or UP-UE trace.
    ...                '/ffs/run/config/toor4nsn' is a common shared folder between ASIK Master and ASIK Slave,
    ...                So CPRT trace can be downloaded directly at ASIK Master.
    ...                CPRT log should be collected on ASIK Slave.
    ...                UPUE log should be collected on ASIK Master.
    ...                ${check_times} and ${sleep_interval} parameters are mainly for checking process,
    ...                default check 3 times, each check time interval is 1s.
    ...                Return: the trace log path.
    [Arguments]      ${log_prefix}    ${log_dir}=/ffs/run/config/toor4nsn    ${connection_alias}=ASIK Slave
    ...              ${container_name}=0xe005    ${interface}=any    ${check_times}=${3}    ${sleep_interval}=1 sec
    ${trace_timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
    ${log_name}    Set variable    ${log_prefix}_${trace_timestamp}.pcap
    ${log_full_path}    join path    ${log_dir}    ${log_name}
    ${tcpdump_command}    Set variable    setsid lxc-attach -n ${container_name} -- tcpdump -i ${interface} -s 0 -w ${log_full_path}
    ${connection}    csn.get_connection_by_alias    alias=${connection_alias}
    ${channel}    call method    ${connection}    invoke_shell
    call method    ${channel}    settimeout    ${10}
    call method    ${channel}    send    ${tcpdump_command}\n
    call method    ${channel}    settimeout    ${3}
    call method    ${channel}    recv    ${65535}
    call method    ${channel}    close
    Trace capturing process should be triggered    log_prefix=${log_prefix}    connection_alias=${connection_alias}
    ...    check_times=${check_times}    sleep_interval=${sleep_interval}
    [Return]           ${log_full_path}

Start CP-IF trace capturing
    [Documentation]    Author: Chen Jun
    ...                Start CP-IF trace capturing with retry.
    ...                Sometimes, trace capturing process may not startup successfully.
    ...                So add retry for log capturing.
    ...                if user would like to capture CP-IF log for feature 1514, it will captureing on ASIB Master or ASIK Slave.
    [Arguments]      ${CPIF_log_prefix}    ${CPIF_log_dir_asik}=/user/toor4nsn       ${asik_connection_alias}=ASIK Master
    ...              ${retry_time}=10    ${local_node_id}=0x1011    ${node_name}=CPIF    ${hw_slot}=${1}
    ...              ${interface}=any    ${gnb_index}=${0}    ${du_index}=${0}    ${asik_slave_alias}=ASIK Slave
    ...              ${local_slave_node_id}=0x1021
    ${asib_flag}    If ASIB card used    gnb_index=${gnb_index}    du_index=${du_index}    alias=${asik_connection_alias}
    Set Test Variable    ${asib_flag}
    ${is_feature_1948_enabled}    Is Feature 1948 Enabled    connection_alias=${asik_connection_alias}    local_node_id=${local_node_id}
    Run Keyword If    ${asib_flag}==${False}    Connect to Common Unit Slave
    ...    du_index=${du_index}    alias=${asik_slave_alias}    gnb_index=${gnb_index}    asik_alias=${asik_connection_alias}
    ${local_node_id}    Set Variable If
    ...    ${asib_flag}    ${local_node_id}
    ...    '${asib_flag}'=='${False}' and '${is_feature_1948_enabled}'=='${True}'    ${local_slave_node_id}
    ...    '${asib_flag}'=='${False}' and '${is_feature_1948_enabled}'=='${False}'    ${local_node_id}
    ${container_id}    Get the container id for specific nodename    local_node_id=${local_node_id}
    ...    node_name=${node_name}    connection_alias=${asik_connection_alias}    gnb_index=${gnb_index}
    ${container_id}    convert to lowercase    ${container_id}
    ${container_name}    Set variable     ${container_id}
    ${asik_connection_alias}    Set Variable If
    ...    ${asib_flag}    ${asik_connection_alias}
    ...    '${asib_flag}'=='${False}' and '${is_feature_1948_enabled}'=='${True}'    ${asik_slave_alias}
    ...    '${asib_flag}'=='${False}' and '${is_feature_1948_enabled}'=='${False}'    ${asik_connection_alias}
    ${full_path}       Wait until keyword succeeds    ${retry_time}X    3 s
    ...    Start trace capturing without duration on container    log_prefix=${CPIF_log_prefix}
    ...    log_dir=${CPIF_log_dir_asik}   connection_alias=${asik_connection_alias}    container_name=${container_name}
    ...    interface=${interface}
    [Return]    ${full_path}

Start CPRT trace capturing
    [Documentation]    Author: Wang Yixiang
    ...                Start CP-RT trace capturing with retry.
    ...                Sometimes, trace capturing process may not startup successfully.
    ...                So add retry for log capturing.
    ...                if user would like to capture CP-RT log for feature 1514, it will captureing on ASIK Slave.
    ...                If using ASIB, CPRT log should be captured on master, ASIB has no slave, and local_node_id=0x1011,
    ...                   connection_alias=ASIK Master
    [Arguments]      ${CPRT_log_prefix}    ${CPRT_log_dir_asik}=/ffs/run/config/toor4nsn      ${asik_connection_alias}=ASIK Master
    ...              ${retry_time}=10    ${local_node_id}=0x1011   ${local_slave_node_id}=0x1021    ${node_name}=CPRT     ${gnb_index}=${0}
    ...              ${du_index}=${0}   ${hw_slot}=${1}    ${asik_slave_alias}=ASIK Slave   ${interface}=any
    ${asib_flag}    If ASIB card used
    csn.connect_to    hostname=${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...               username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               alias=${asik_connection_alias}
    #${is_feature_1514_enabled}    stream_manager.feature_1514_opened    connection=${asik_connection_alias}
    #${is_feature_1948_enabled}    Is Feature 1948 Enabled    connection_alias=${asik_connection_alias}    local_node_id=${local_node_id}
    Run Keyword If     ${asib_flag}==${False}     Connect to Common Unit Slave
    ...    du_index=${du_index}    alias=${asik_slave_alias}    gnb_index=${gnb_index}    asik_alias=${asik_connection_alias}
    ${local_node_id}    Set Variable If    ${asib_flag}==${False}    ${local_slave_node_id}    ${local_node_id}
    #${container_id}    run keyword if    ${is_feature_1514_enabled}    Get the container id for specific nodename    local_node_id=${local_node_id}
    #...    node_name=${node_name}    connection_alias=${asik_connection_alias}
    ${container_id}     Get the container id for specific nodename    local_node_id=${local_node_id}
    ...    node_name=${node_name}    connection_alias=${asik_connection_alias}
    #${container_id}   run keyword if    ${is_feature_1514_enabled}    convert to lowercase    ${container_id}
    ${container_id}   convert to lowercase    ${container_id}
    #${container_name}    Set variable if     ${is_feature_1514_enabled}    ${container_id}    0xe005
    ${container_name}    Set variable     ${container_id}
    ${asik_connection_alias}    Set Variable If    ${asib_flag}==${False}     ${asik_slave_alias}    ${asik_connection_alias}
    ${full_path}       Wait until keyword succeeds    ${retry_time}X    3 s
    ...    Start trace capturing without duration on container    log_prefix=${CPRT_log_prefix}
    ...    log_dir=${CPRT_log_dir_asik}   connection_alias=${asik_connection_alias}    container_name=${container_name}
    ...    interface=${interface}
    [Return]    ${full_path}

Get the container id for specific nodename
    [Documentation]    Author: Liu Zheng
    ...    :param ${local_node_id}: refer to ASIK/ABIL Master/Slave node id, eg, 0x1011, 0x123D
    ...    :param ${node_name}: refer to container name, eg, UPUE, CPIF
    ...    2020/04/22 Cui Lingxue: extend to support both trunk and other branch.
    [Arguments]    ${local_node_id}   ${node_name}    ${connection_alias}=ASIK Master    ${gnb_index}=${0}    ${du_index}=${0}
    csn.connect_to    hostname=${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...               username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               alias=${connection_alias}
    #${is_feature_1514_enabled}    stream_manager.feature_1514_opened    connection=${connection_alias}
    #csn.connect_to    hostname=${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    #...               username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    #...               password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    #...               alias=${connection_alias}
    #${cmd}    run keyword if    ${is_feature_1514_enabled}
    #...    Catenate    export PYTHONPATH=/opt/hwmt/python; python3 /opt/hwmt/python/hwapi/SupervisorS.py -n ${local_node_id} -o list_cbts
    #...              -p 15004 | grep -i ${node_name} |awk '{print $2}'
    #...    ELSE    Catenate    export PYTHONPATH=/opt/hwmt/python; python /opt/hwmt/python/hwapi/SupervisorS.py -n ${local_node_id} -o list_cbts
    #...              | grep -i ${node_name} |awk '{print $2}'
    ${cmd}    Catenate    export PYTHONPATH=/opt/hwmt/python; python3 /opt/hwmt/python/hwapi/SupervisorS.py -n ${local_node_id} -o list_cbts
    ...              -p 15004 | grep -i ${node_name} |awk '{print $2}'

    ${cmd_output}    csn.Execute    command=${cmd}    connection=${connection_alias}
    ${output_len}    Get length    ${cmd_output}
    Should be true    ${output_len} > ${0}    msg=there is no ${node_name} in ${local_node_id}.
    ${container_id_tmp}    fetch from left    ${cmd_output}    ,
    ${container_id}    fetch from right    ${container_id_tmp}    :
    [Return]    ${container_id}

Is trace capturing process exist
    [Documentation]    Author: Liu Zheng
    ...                Check if the tcpdump process is triggered .
    [Arguments]         ${log_prefix}    ${connection_alias}=ASIK Slave
    ${check_process}    csn.Execute    ps -ef | grep tcpdump | grep -v grep | grep ${log_prefix}
    ...                  connection=${connection_alias}
    ${check_process}    Strip string    ${check_process}
    ${output_len}    Get length    ${check_process}
    ${is_process_exist}    set variable if    ${output_len}!=0    ${True}    ${False}
    [Return]    ${is_process_exist}

Trace capturing process should be triggered
    [Documentation]    Author: Liu Zheng
    ...                Make sure tcpdump process should be triggered.
    ...                There is tcpdump process after start the tcpdump process,
    ...                but when to stop the process, the tcpdump process disappeared in rare cases.
    ...                So to make sure the process is really trigged, there are default three check times to make sure tcpdump process exist.
    [Arguments]         ${log_prefix}    ${connection_alias}=ASIK Slave    ${check_times}=${3}    ${sleep_interval}=1 sec
    FOR    ${check_time}    IN RANGE    ${check_times}
        ${is_process_exist}    Is trace capturing process exist    log_prefix=${log_prefix}    connection_alias=${connection_alias}
        exit for loop if    ${is_process_exist}
        Sleep    ${sleep_interval}
    END
    Should be equal as strings    ${is_process_exist}    True

Stop trace capturing
    [Documentation]    Author: Liu Zheng
    ...                Stop trace process.
    ...    2020/04/23 Cui Lingxue: add retry logic
    [Arguments]        ${log_prefix}    ${connection_alias}=ASIK Slave    ${retry_time}=10
    FOR    ${i}    IN RANGE    ${retry_time}
        csn.execute    ps -ef | grep tcpdump | grep -v grep | grep ${log_prefix} | awk '{print $2}' | xargs kill -2
        ...    connection=${connection_alias}
        ${is_trace_capture_stopped}    run keyword and return status    wait until keyword succeeds    5s    200ms
        ...    Trace capturing process should be stopped    log_prefix=${log_prefix}    connection_alias=${connection_alias}
        exit for loop if    ${is_trace_capture_stopped}==${True}
    END
    should be true    ${is_trace_capture_stopped}

Trace capturing process should be stopped
    [Documentation]    Author: Cui Lingxue
    ...    check if tcpdump process is stopped.
    [Arguments]         ${log_prefix}    ${connection_alias}=ASIK Slave
    ${is_process_exist}    Is trace capturing process exist    log_prefix=${log_prefix}    connection_alias=${connection_alias}
    should be true    ${is_process_exist}==${False}

Download trace log
    [Documentation]    Author: Liu Zheng
    ...                This keyword is used to download the captured trace log to test PC.
    ...                e.g. download CPRT or UPUE trace from ASIK to the test PC.
    ...                'log_full_path' is log file with log path, e.g. /ffs/run/config/toor4nsn/CPRT.pcap
    ...                '/ffs/run/config/toor4nsn' is a common shared folder between ASIK Master and ASIK Slave.
    ...                Return: the file path on ute
    [Arguments]         ${log_full_path}    ${log_dir_ute}=${TS_CASE_LOG_PATH}
    ...                 ${connection_alias}=ASIK Master
    ${log_name}    Fetch from right    ${log_full_path}    /
    ${log_full_path_ute}     join path    ${log_dir_ute}    ${log_name}
    csn.download file   remote_path=${log_full_path}
    ...                 local_path=${log_full_path_ute}
    ...                 connection=${connection_alias}
    [Teardown]    csn.execute         command=rm ${log_full_path}    connection=${connection_alias}
    [Return]    ${log_full_path_ute}

Get SW version from gnb
    [Documentation]    Author: Wang Yixiang
    ...    Get AirAcale software version from Master
    ...    e.g return value:AirScale-0.800.445_ASIB_ABIL, AirScale-7.3836.114, AirScale-0.800.445_ASIK_ABIL
    Connect to Common Unit Master
    ${gnb_sw_version}=    ssh.execute    sed -nr 's/.*swReleaseVersionPackageName\="([A-Za-z0-9\.\_\-]+)".*/\\1/p' /ffs/run/TargetBD*.xml
    ...    connection=ASIK Master
    log    gNB sw version:${gnb_sw_version}
    [Return]    ${gnb_sw_version}

Stop tcpdump
    [Documentation]    Author: Deng xueqin
    ...                This keyword is to stop tcpdump.
    ...                :param ${target_dir}: file name part of the path under which the pcap file is stored
    ...                :param ${name}: name of collector, default: tcpdump
    [Arguments]    ${target_dir}    ${name}=tcpdump
    core.stop_collectors    names=${name}
    core.collect_collectors    names=${name}     target_dir=${target_dir}
    core.teardown_collectors    names=${name}

Load pcap with filter
    [Documentation]    Author: Deng xueqin
    ...                This key word is to load pcap file with filter condition.
    ...                :param ${pcap_file}: pcap file to load, e.g. /tmp/tcpdump_tcpdump.pcap
    ...                :param ${filter_expression}: wireshark filter expression, e.g. vlan.id == 295
    ...                :param ${tshark_path}: path of tshark executable, default:/usr/bin/tshark
    ...                :param ${luashark_path}: path of luashark file
    ...                :param ${command_template}: tshark command template of pcap to pdml conversion
    ...                Return: filtered packets in the pcap log with PdmlLogEntry format
    [Arguments]    ${pcap_file}    ${filter_expression}    ${tshark_path}=/usr/bin/tshark
    ...            ${luashark_path}=${None}    ${command_template}=${None}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${pcap_file}
        ...    tshark_path=${tshark_path}
        ...    luashark_path=${luashark_path}
        ...    command_template=${command_template}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
    [Return]    ${filtered_packets}

Get field value
    [Documentation]    Author: Deng xueqin
    ...                This key word is to load pcap file with filter condition.
    ...                :param ${packets}: a list contains only one generator
    ...                :param ${field_name}: field name in a packet, e.g. vlan.priority
    ...                :param ${attribute_name}: attribute of packet field, e.g. “show”, “value”, or “showname”, default: “show”
    ...                Return: field value list
    [Arguments]    ${packets}    ${field_name}    ${attribute_name}=show
    ${values}    cap.get_field_value_by_name    field_name=${field_name}    attribute_name=${attribute_name}
    [Return]    ${values}

Start tcpdump log on CU
    [Documentation]    Author: Wang Yixiang
    ...                create tcpdump log collection on CU
    ...                gnb_id: gnb_id default value:0
    ...                tcpdump_collector_name: name of the collector. Ex: cpif_tcpdump
    ...                options: (optional) tcpdump options (except for “-w”), can be -i any, -i internal
    ...                vm_name: vm host name
    ...                    oam-0.local, uvm-0.local, cpnb-0.local, cpif-0.local, upue-0.local, cpnrt-0.local,
    ...                    db.local, cpcl-0.local, cpue-0.local
    [Arguments]      ${gnb_id}=0    ${tcpdump_collector_name}=cpif_tcpdump    ${options}=-i any    ${vm_name}=cpif-0.local
    &{oam_config}=   create dictionary     host=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.addr}
    ...                                    user=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.username}
    ...                                    password=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.password}
    &{vm_config}=    create dictionary     host=${vm_name}
    ...                                    user=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.username}
    ...                                    password=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.password}
    ...                                    proxy=${oam_config}
    tcpdump.create_tcpdump_collector       name=${tcpdump_collector_name}   options=${options}   executor=${vm_config}
    tcpdump.Set Suite Alias                ${tcpdump_collector_name}
    core.setup_collectors                  names=${tcpdump_collector_name}
    core.start_collectors                  names=${tcpdump_collector_name}

Stop tcpdump log collection
    [Documentation]    Author: Wang Yixiang
    ...                stop tcpdump log collection and return log path
    [Arguments]      ${tcpdump_collector_name}=cpif_tcpdump    ${target_dir}=${TS_CASE_LOG_PATH}
    ${log_path}    Stop and download log via collector    collector_name=${tcpdump_collector_name}    pattern=*.pcap    target_dir=${target_dir}
    [Return]     ${log_path}

Stop and download log via collector
    [Documentation]    Author: Wang Yixiang
    ...                keyword is used to collect the log files to default path
    [Arguments]      ${collector_name}    ${pattern}=*    ${target_dir}=${TS_CASE_LOG_PATH}    ${sleep_interval}=1 sec
    core.stop_collectors        names=${collector_name}
    core.collect_collectors   names=${collector_name}    target_dir=${target_dir}
    core.teardown_collectors    names=${collector_name}
    Sleep    ${sleep_interval}
    @{log_file}   List Files In Directory    path=${target_dir}${/}${collector_name}    pattern=${pattern}
    ${list_len}    get length    ${log_file}
    Should be true    ${list_len}==1
    ${full_log_path}    set variable    ${target_dir}${/}${collector_name}${/}${log_file}[0]
    [Return]     ${full_log_path}

Stop Tcpdump via collector
    [Documentation]    Author: Cheng Catherine
    ...                keyword is used to stop the tcpdump
    [Arguments]      ${collector_name}
    core.stop_collectors        names=${collector_name}
    core.teardown_collectors    names=${collector_name}


Is Feature 1948 Enabled
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                Check if 1948 faeture is enabled. If 1948 is enable, CPIF/cpcl/cpnb in ASIK slave, else, cpif/cpcl/cpnb
    ...                in ASIK master.  For ASIB, cpif in ASIB master.
    [Arguments]    ${connection_alias}=ASIK Master    ${local_node_id}=0x1011
    ${cmd}    Catenate    export PYTHONPATH=/opt/hwmt/python; python3 /opt/hwmt/python/hwapi/SupervisorS.py -n ${local_node_id} -o list_cbts
    ...                   -p 15004 | grep -i CPIF |awk '{print $2}'
    ${cmd_output}    csn.Execute    command=${cmd}    connection=${connection_alias}
    ${output_len}    Get Length    ${cmd_output}
    ${is_feature_1948_enabled}    Set Variable If    ${output_len}==0    ${True}    ${False}
    [Return]    ${is_feature_1948_enabled}

Start CP-IF Log Collection
    [Documentation]    Author: Chen Jun
    ...                create tcpdump log collection on ASIK slave/ASIB master.
    ...                options: (optional) tcpdump options (except for “-w”), default: empty string
    ...                stop tcpdump can use:Stop tcpdump log collection
    ...                parma: ${container_name} if ${container_name}=${None}, it will capture the log without access into any container.
    [Arguments]      ${tcpdump_collector_name}=cpif_tcpdump    ${asik_connection_alias}=ASIK Master
    ...              ${options}=-i any -s 0    ${gnb_index}=${0}    ${du_index}=${0}    ${container_name}=CPIF
    ${asib_flag}    If ASIB card used    gnb_index=${gnb_index}    du_index=${du_index}    alias=${asik_connection_alias}
    ${is_left_enabled}    If GNB In Left Side Of AMIA    connection=${asik_connection_alias}
    ${local_node_id}    Set Variable If   ${is_left_enabled}    0x1011     0x2011
    ${is_feature_1948_enabled}    Is Feature 1948 Enabled    connection_alias=${asik_connection_alias}    local_node_id=${local_node_id}
    &{master_config}   create dictionary
    ...    host=${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...    user=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ${slave_host_ip}    Set Variable If    ${is_left_enabled}    192.168.253.17     192.168.253.33
    &{slave_config}  create dictionary
    ...    host=${slave_host_ip}
    ...    user=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    proxy=${master_config}
    ${executor_oam_vm}    Set Variable If
    ...    ${asib_flag}    ${master_config}
    ...    '${asib_flag}'=='${False}' and '${is_feature_1948_enabled}'=='${True}'    ${slave_config}
    ...    '${asib_flag}'=='${False}' and '${is_feature_1948_enabled}'=='${False}'    ${master_config}
    tcpdump.create_tcpdump_collector    name=${tcpdump_collector_name}
    ...                                 options=${options}
    ...                                 executor=${executor_oam_vm}
    ...                                 container=${container_name}
    tcpdump.Set Suite Alias    ${tcpdump_collector_name}
    core.setup_collectors    names=${tcpdump_collector_name}
    core.start_collectors    names=${tcpdump_collector_name}
