*** Settings ***
Documentation
...    Author: Liu, Renhui
...    Contact: renhui-david.liu@nokia-sbell.com

Resource          common/product_config_reader.robot
Library           taf.collectors.snapshot               WITH NAME    classcial_snapshot
Library           taf.collectors.btslog                 WITH NAME    classcial_btslog
Library           taf.collectors.tcpdump                WITH NAME    classcial_tcpdump
Library           taf.sbts.oam.coam.admin               WITH NAME    classcial_coam
Library           common/gnb_tool.py                    WITH NAME    classcial_gnb_tool
Library           common/log_metadata.py                WITH NAME    metadata
Library           common/common_utils.py                WITH NAME    utility




*** Keywords ***
classical_worker.Start To Collect Syslog Log
    [Arguments]    ${product_type}
    ...            ${bts_index}=${0}
    ...            ${connection}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to collect syslog from vdu or vcu.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | product_type | Yes | gnb, enb |
    ...    | bts_index | Yes | The list index from tl.cu[]  |
    ...    | connection | Yes | an alias for reusing an existing connection later |
    ...    | timeout | No | timeout |
    ...    *Example:*
    ...        - cloud_worker.Start To Collect Syslog Log
    ...
    Log To Console    ${product_type}
    Log To Console    ${timeout}
    ${bts_http_con_info}    Run Keyword If    '${bts_index}' == '0'
    ...    classical_worker._Start To Collect Syslog Log From Local VM    ${connection}
    ...    ELSE
    ...    classical_worker._Start To Collect Syslog Log From Remote VM    ${bts_index}    ${connection}

classical_worker.Stop and Download Syslog Log
    [Arguments]    ${connection}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to stop and download syslog Logs.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | connection | Yes | an alias for reusing an existing connection later |
    ...    *Example:*
    ...        - classical_worker.Stop and Download Syslog Log
    ...
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${log_dir_by_level}=    _CommonBTS.Get Log Directory For Log Module By Level
    ${target_dir}=    Join Path    ${log_dir_by_level}    ${connection}_${timestamp}
    utility.create_local_directory    ${target_dir}
    log_module_core.stop_collectors      names=${connection}
    log_module_core.collect_collectors      names=${connection}    target_dir=${target_dir}
    [Return]    ${target_dir}/${connection}
    [Teardown]    run keyword and ignore error    log_module_core.teardown_collectors    names=${connection}

classical_worker.Start To Collect Snapshot Log
    [Arguments]    ${product_type}
    ...            ${bts_index}=${0}
    ...            ${connection}=${None}
    ...            ${coverage}=Full
    ...            ${force}=0
    ...            ${timeout}=${1200}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to collect Snapshot from gnb or enb.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | product_type | Yes | gnb, enb |
    ...    | bts_index | Yes | The list index from tl.cu[] |
    ...    | connection | Yes | an alias for reusing an existing connection later  |
    ...    | timeout | No | timeout |
    ...    *Example:*
    ...        - classical_worker.Start To Collect Snapshot Log
    ...
    ${bts_http_con_info}    Run Keyword If    '${bts_index}' == '0'
    ...    product_config.Get BTS LMP HTTP Connection Info    product_type=${product_type}    bts_index=${bts_index}
    ...    ELSE
    ...    product_config.Get BTS OAM HTTP Connection Info    product_type=${product_type}    bts_index=${bts_index}
    &{webservice}=    Create Dictionary    host=${bts_http_con_info["host"]}
    ...                                    user=${bts_http_con_info["username"]}
    ...                                    password=${bts_http_con_info["password"]}
    ...                                    port=${bts_http_con_info["port"]}
    classcial_snapshot.Create Sbts Snapshot Collector    name=${connection}    webservice=${webservice}
    ...    coverage=${coverage}    force=${force}   timeout=${timeout}
    log_module_core.Setup Collectors    names=${connection}
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${log_dir_by_level}=    _CommonBTS.Get Log Directory For Log Module By Level
    ${target_dir}=    Join Path    ${log_dir_by_level}    ${connection}_${timestamp}
    utility.create_local_directory    ${target_dir}
    log_module_core.Collect Collectors    names=${connection}    target_dir=${target_dir}
    [Return]    ${target_dir}/${connection}
    [Teardown]    Run Keyword And Ignore Error    log_module_core.Teardown Collectors    names=${connection}

classical_worker.Start To Collect Bip Log
    [Arguments]    ${product_type}
    ...            ${bts_index}=${0}
    ...            ${connection}=${None}
    ...            ${add_options}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to collect bip from gnb.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | product_type | Yes | gnb, enb |
    ...    | bts_index | Yes | The list index from tl.cu[] |
    ...    | connection | Yes | an alias for reusing an existing connection later  |
    ...    | timeout | No | timeout |
    ...    *Example:*
    ...        - classical_worker.Start To Collect Bip Log
    ...
    Log To Console    ${connection}
    Log To Console    ${timeout}
    Log To Console    \nStart to prepare gnb tool
    classcial_gnb_tool.prepare_gnb_tool
    sleep   1s
    ${bts_http_con_info}=    product_config.Get BTS OAM HTTP Connection Info
    ...    product_type=${product_type}    bts_index=${bts_index}
    ${oam_ip}=    set variable    ${bts_http_con_info["host"]}
    Log To Console    \nStart to collect bip
    ${log_dir_by_level}=    _CommonBTS.Get Log Directory For Log Module By Level
    classcial_gnb_tool.Start To Capture Bip Log With Gnb Tool
    ...    log_dire=${log_dir_by_level}
    ...    host=127.0.0.1
    ...    dest_ip=${oam_ip}
    ...    add_options=${add_options}

classical_worker.Stop and Download Bip Log
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to stop and download bip Logs.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | connection | Yes | an alias for reusing an existing connection later |
    ...    *Example:*
    ...        - classical_worker.Stop and Download Bip Log
    ...
    Log To Console    \nStopping and Downloading bip log with gnb_tool
    ${log_path}    classcial_gnb_tool.stop_bip_log_with_gnb_tool
    [Return]    ${log_path}

classical_worker.Start To Collect Wireshark Log
    [Arguments]    ${product_type}
    ...            ${bts_index}=${0}
    ...            ${connection}=${None}
    ...            ${wireshark_options}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to collect Wireshark.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | product_type | Yes | gnb, enb |
    ...    | bts_index | Yes | The list index from tl.cu[] |
    ...    | connection | Yes | an alias for reusing an existing connection later  |
    ...    | timeout | No | timeout |
    ...    *Example:*
    ...        - classical_worker.Start To Collect Wireshark Log
    ...
    Log To Console    ${timeout}
    Log To Console    \nStarting to collect wireshark log
    ${webservice}    Run Keyword If    '${bts_index}' == '0'
    ...    product_config.Get BTS LMP SSH Connection Info    product_type=${product_type}    bts_index=${bts_index}
    ...    ELSE
    ...    product_config.Get BTS OAM SSH Connection Info   product_type=${product_type}    bts_index=${bts_index}

    classcial_tcpdump.create_tcpdump_collector    name=${connection}
    ...    options=${wireshark_options}    executor=${webservice}
    classcial_tcpdump.Set Suite Alias    ${connection}
    log_module_core.setup_collectors    names=${connection}
    log_module_core.start_collectors    names=${connection}

classical_worker.Stop and Download Wireshark Log
    [Arguments]    ${connection}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to stop and download Wireshark Logs.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | connection | Yes | an alias for reusing an existing connection later |
    ...    *Example:*
    ...        - classical_worker.Stop and Download Wireshark Log
    ...
    Log To Console    \nStopping and downloading wireshark log
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${log_dir_by_level}=    _CommonBTS.Get Log Directory For Log Module By Level
    ${target_dir}=    Join Path    ${log_dir_by_level}    ${connection}_${timestamp}
    utility.create_local_directory    ${target_dir}
    log_module_core.stop_collectors      names=${connection}
    log_module_core.collect_collectors      names=${connection}    target_dir=${target_dir}
    ${local_file_path} =    Set Variable    ${target_dir}/${connection}/${connection}.pcap
    [Return]    ${local_file_path}
    [Teardown]    run keyword and ignore error    log_module_core.teardown_collectors    names=${connection}

classical_worker.Start To Collect TTI Log
    [Arguments]    ${product_type}
    ...            ${bts_index}=${0}
    ...            ${connection}=${None}
    ...            ${add_options}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to collect tti from gnb.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | product_type | Yes | gnb, enb |
    ...    | bts_index | Yes | The list index from tl.cu[] |
    ...    | connection | Yes | an alias for reusing an existing connection later  |
    ...    | timeout | No | timeout |
    ...    *Example:*
    ...        - classical_worker.Start To Collect Bip Log
    ...
    Log To Console    ${connection}
    Log To Console    ${timeout}
    Log To Console    \nStart to prepare gnb tool
    classcial_gnb_tool.prepare_gnb_tool
    sleep   1s
    ${bts_http_con_info}=    product_config.Get BTS OAM HTTP Connection Info
    ...    product_type=${product_type}    bts_index=${bts_index}
    ${oam_ip}=    set variable    ${bts_http_con_info["host"]}
    Log To Console    \nStart to collect tti
    ${log_dir_by_level}=    _CommonBTS.Get Log Directory For Log Module By Level
    classcial_gnb_tool.start_to_capture_tti_log_with_gnb_tool
    ...    log_dire=${log_dir_by_level}
    ...    host=127.0.0.1
    ...    dest_ip=${oam_ip}
    ...    add_options=${add_options}
#    ...    add_options=-t ${t_time} -C ${cell_tti}

classical_worker.Stop and Download TTI Log
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to stop and download tti Logs.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | connection | Yes | an alias for reusing an existing connection later |
    ...    *Example:*
    ...        - classical_worker.Stop and Download TTI Log
    ...
    Log To Console    \nStopping and Downloading TTI log with gnb_tool
    ${log_path}    classcial_gnb_tool.stop_tti_log_with_gnb_tool
    [Return]    ${log_path}

#---------------------Supported--------------------------------------------------------------------------
classical_worker._Start To Collect Syslog Log From Local VM
    [Arguments]    ${connection}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to collect syslog from gnb or enb.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | connection | Yes | an alias for reusing an existing connection later |
    ...    *Example:*
    ...        - classical_worker._Start To Collect Syslog Log From Local VM
    ...
    ${log_dir}=    set variable    /tmp/btslog2
    utility.create_local_directory    ${log_dir}
    classcial_btslog.create_btslog_collector
    ...    name=${connection}
    ...    log_dir=${log_dir}
    classcial_btslog.Set Suite Alias    ${connection}
    log_module_core.setup_collectors      names=${connection}
    log_module_core.start_collectors      names=${connection}

classical_worker._Start To Collect Syslog Log From Remote VM
    [Arguments]    ${bts_index}
    ...            ${connection}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to collect syslog from a remote VM.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | bts_index | Yes | The list index from tl.cu[] |
    ...    | connection | Yes | an alias for reusing an existing connection later |
    ...    *Example:*
    ...        - classical_worker._Start To Collect Syslog Log From Remote VM
    ...
    ${executor_test_vm}=     product_config.Get Test PC SSH Connection Info    bts_index=${bts_index}
    classcial_btslog.create_btslog_collector
    ...   name=${connection}
    ...   btslog_path=/opt/btslog/btslog
    ...   btslog_launcher_path=/opt/btslog/btslog_launcher
    ...   executor=${executor_test_vm}
    ...   log_dir=/tmp/btslog2
    classcial_btslog.Set Suite Alias    ${connection}
    log_module_core.setup_collectors      names=${connection}
    log_module_core.start_collectors      names=${connection}


################################ Manage connection name #################################
classical_worker.get_connection_name
    [Arguments]    ${log_type}
    ...            ${product_type}
    ...            ${bts_index}=${0}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to get an connection name.
    ...        - The name is automatically generated according to convention.
    ...        - The advantage of this is to free the end users from managing aliases everywhere.
    ...        - The convention for name is:
    ...        -     ${log_type}_${product_type}${bts_index}
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | log_type | Yes | bip, wireshark, tti, syslog, snapshot, etc. |
    ...    | product_type | Yes | gnb, enb |
    ...    | bts_index | Yes | The list index from tl.cu[]  |
    ...    *Example:*
    ...        - classical_worker.get_connection_name
    ...
    [Return]    ${log_type}_${product_type}${bts_index}

classical_worker.Get BTS Active Software Version
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
    ...        - classical_worker.Get BTS Active Software Version
    ...
    Log To Console    ${cudu_index}
    ${bts_oam_http_connection_info}=    product_config.Get BTS OAM HTTP Connection Info
    ...    ${product_type}    bts_index=${bts_index}
    classical_worker.Connect To BTS By Rest    ${connection}    &{bts_oam_http_connection_info}    timeout=${timeout}

    ${sw_info}    classcial_coam.get_software_info    connection=${connection}    timeout=${timeout}
    ${bts_version}    Set Variable    ${sw_info['Active SW version']}
    [Teardown]    Run Keyword And Ignore Error    classical_worker.Disconnect From BTS    ${connection}
    [Return]    ${bts_version}

classical_worker.Connect To BTS By Rest
    [Arguments]   ${connection}    ${host}    ${username}    ${password}    ${port}    ${timeout}=${10}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to connect to classical BTS By Rest.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | product_type | Yes | vdu, vcu |
    ...    | bts_index | Yes | The list index from tl.cu[]  |
    ...    | cudu_index | Yes | the index of cu, du or classical bts  |
    ...    | connection | Yes | an alias for reusing an existing connection later  |
    ...    | timeout | No |   |
    ...    *Example:*
    ...        - classical_worker.Connect To BTS By Rest
    ...
    classcial_coam.connect to
    ...    bts_host=${host}
    ...    bts_port=${port}
    ...    username=${username}
    ...    password=${password}
    ...    use_ssl=${True}
    ...    update_interval=${5000}
    ...    name=${connection}
    ...    timeout=${timeout}

classical_worker.Disconnect From BTS
    [Arguments]   ${connection}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to disconnect from classical BTS By Rest.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | product_type | Yes | vdu, vcu |
    ...    | bts_index | Yes | The list index from tl.cu[]  |
    ...    | cudu_index | Yes | the index of cu, du or classical bts  |
    ...    | connection | Yes | an alias for reusing an existing connection later  |
    ...    | timeout | No |   |
    ...    *Example:*
    ...        - classical_worker.Disconnect From BTS
    ...
    classcial_coam.teardown    connection=${connection}
