*** Settings ***
Documentation
...    Author: Liu, Renhui
...    Contact: renhui-david.liu@nokia-sbell.com
...    Theese KWs should be unexposed to user. It is internally used to collect logs for Cloud RAN.


Library           Collections
Library           DateTime
Library           OperatingSystem
Library           Process
Library           String
Library           yaml
Library           json
Resource          log_worker/cloud_log_worker.robot


*** Variables ***
${TEMPLATE_PATH}    ${CURDIR}/../config/log_parameters_template.yml
&{vdu_log_type_dict}    emil=controlPlane5gVdu    tti=L2Ps_Component      cell_trace=tracerVdu
...                     syslog=syslogVdu          snapshot=snapshotVdu
&{vcu_log_type_dict}    emil=controlPlane5gVcu    tti=L2HiPdcp_Component      cell_trace=tracerVcu
...                     syslog=syslogVcu        snapshot=snapshotVcu

*** Keywords ***
_CloudRAN.start_wireshark_oam_log
    [Arguments]    ${log_type}
    ...            ${product_type}=vdu
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${dict_argument}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to start to collect wireshark mplane Log.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | log_type | Yes | bip, wireshark, tti, syslog, snapshot, etc. |
    ...    | product_type | Yes | vdu, vcu, classical |
    ...    | bts_index | Yes | The list index from tl.cu[]  |
    ...    | cudu_index | Yes | the index of cu, du or classical bts  |
    ...    | dict_argument | No |  { dcap_server: {host: x, username: x, password: x, port: x}, argument: {} } |
    ...    | timeout | No |    |
    ...
    _CloudRAN.start_wireshark_log        ${log_type}
    ...            product_type=${product_type}
    ...            bts_index=${bts_index}
    ...            cudu_index=${cudu_index}
    ...            dict_argument=${dict_argument}
    ...            timeout=${timeout}

_CloudRAN.stop_and_download_wireshark_oam_log
    [Arguments]    ${log_type}
    ...            ${product_type}=vdu
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${dict_argument}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to stop and download wireshark mplane Log.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | log_type | Yes | bip, wireshark, tti, syslog, snapshot, etc. |
    ...    | product_type | Yes | vdu, vcu, classical |
    ...    | bts_index | Yes | The list index from tl.cu[]  |
    ...    | cudu_index | Yes | the index of cu, du or classical bts  |
    ...    | dict_argument | No |  { dcap_server: {host: x, username: x, password: x, port: x}, argument: {} } |
    ...    | timeout | No |    |
    ...    *Example:*
    ...        - _CloudRAN.stop_and_download_wireshark_oam_log
    ...
    ${local_file_path}=    _CloudRAN.stop_and_download_wireshark_log    ${log_type}
    ...            product_type=${product_type}
    ...            bts_index=${bts_index}
    ...            cudu_index=${cudu_index}
    ...            dict_argument=${dict_argument}
    ...            timeout=${timeout}
    [Return]   ${local_file_path}

_CloudRAN.start_wireshark_cp_log
    [Arguments]    ${log_type}
    ...            ${product_type}=vdu
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${dict_argument}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to start to collect wireshark cplane Log.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | log_type | Yes | bip, wireshark, tti, syslog, snapshot, etc. |
    ...    | product_type | Yes | vdu, vcu, classical |
    ...    | bts_index | Yes | The list index from tl.cu[]  |
    ...    | cudu_index | Yes | the index of cu, du or classical bts  |
    ...    | dict_argument | No |  { dcap_server: {host: x, username: x, password: x, port: x}, argument: {} } |
    ...    | timeout | No |    |
    ...
    _CloudRAN.start_wireshark_log        ${log_type}
    ...            product_type=${product_type}
    ...            bts_index=${bts_index}
    ...            cudu_index=${cudu_index}
    ...            dict_argument=${dict_argument}
    ...            timeout=${timeout}

_CloudRAN.stop_and_download_wireshark_cp_log
    [Arguments]    ${log_type}
    ...            ${product_type}=vdu
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${dict_argument}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to stop and download wireshark Log.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | log_type | Yes | bip, wireshark, tti, syslog, snapshot, etc. |
    ...    | product_type | Yes | vdu, vcu, classical |
    ...    | bts_index | Yes | The list index from tl.cu[]  |
    ...    | cudu_index | Yes | the index of cu, du or classical bts  |
    ...    | dict_argument | No |  { dcap_server: {host: x, username: x, password: x, port: x}, argument: {} } |
    ...    | timeout | No |    |
    ...    *Example:*
    ...        - _CloudRAN.stop_and_download_wireshark_log
    ...
    ${local_file_path}=    _CloudRAN.stop_and_download_wireshark_log    ${log_type}
    ...            product_type=${product_type}
    ...            bts_index=${bts_index}
    ...            cudu_index=${cudu_index}
    ...            dict_argument=${dict_argument}
    ...            timeout=${timeout}
    [Return]   ${local_file_path}

_CloudRAN.start_wireshark_log
    [Arguments]    ${log_type}
    ...            ${product_type}=vdu
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${dict_argument}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to start to collect wireshark Log.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | log_type | Yes | bip, wireshark, tti, syslog, snapshot, etc. |
    ...    | product_type | Yes | vdu, vcu, classical |
    ...    | bts_index | Yes | The list index from tl.cu[]  |
    ...    | cudu_index | Yes | the index of cu, du or classical bts  |
    ...    | dict_argument | No |  { dcap_server: {host: x, username: x, password: x, port: x}, argument: {} } |
    ...    | timeout | No |    |
    ...    *Example:*
    ...        - _CloudRAN.start_wireshark_log
    ...
    ${template_params}=    _CloudRAN.prepare_wireshark_template_params
    ...    log_type=${log_type}
    ...    product_type=${product_type}
    ${connection}=    cloud_worker.get_connection_name    ${log_type}
    ...    product_type=${product_type}    bts_index=${bts_index}    cudu_index=${cudu_index}
    ${wireshark_options}=    utility.check_nested_attributes    ${dict_argument}    argument.wireshark_options
    ${options_upper}=    Convert To Uppercase    ${wireshark_options}
    ${wireshark_interface}    Set Variable If    '${options_upper}' == 'NONE'    any    ${wireshark_options}
    cloud_worker.Start To Collect Wireshark Log
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    cudu_index=${cudu_index}
    ...    wireshark_interface=${wireshark_interface}
    ...    connection=${connection}
    ...    timeout=${timeout}
    ...    &{template_params}

_CloudRAN.stop_and_download_wireshark_log
    [Arguments]    ${log_type}
    ...            ${product_type}=vdu
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${dict_argument}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to stop and download wireshark Log.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | log_type | Yes | bip, wireshark, tti, syslog, snapshot, etc. |
    ...    | product_type | Yes | vdu, vcu, classical |
    ...    | bts_index | Yes | The list index from tl.cu[]  |
    ...    | cudu_index | Yes | the index of cu, du or classical bts  |
    ...    | dict_argument | No |  { dcap_server: {host: x, username: x, password: x, port: x}, argument: {} } |
    ...    | timeout | No |    |
    ...    *Example:*
    ...        - _CloudRAN.stop_and_download_wireshark_log
    ...
    ${template_params}=    _CloudRAN.prepare_wireshark_template_params
    ...    log_type=${log_type}
    ...    product_type=${product_type}
    Remove From Dictionary    ${template_params}    interface    protocol
    ${connection}=    cloud_worker.get_connection_name    ${log_type}
    ...    product_type=${product_type}    bts_index=${bts_index}    cudu_index=${cudu_index}
    ${local_file_path}=    cloud_worker.Stop and Download Wireshark Log
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    cudu_index=${cudu_index}
    ...    connection=${connection}
    ...    timeout=${timeout}
    ...    &{template_params}
    Log    ${dict_argument}
    [Return]   ${local_file_path}

_CloudRAN.start_bip_log
    [Arguments]    ${log_type}
    ...            ${product_type}=vdu
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${dict_argument}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to start to collect Bip Log. Bip log only for vdu.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | log_type | Yes | bip, wireshark, tti, syslog, snapshot, etc. |
    ...    | product_type | Yes | vdu, vcu, classical |
    ...    | bts_index | Yes | The list index from tl.cu[]  |
    ...    | cudu_index | Yes | the index of cu, du or classical bts  |
    ...    | dict_argument | No |  { dcap_server: {host: x, username: x, password: x, port: x}, argument: {} } |
    ...    | timeout | No |    |
    ...    *Example:*
    ...        - _CloudRAN.start_bip_log
    ...
    should be true    '${product_type}'=='vdu'
    ${template_params}=    _CloudRAN.prepare_bip_template_params    log_type=${log_type}
    ${connection}=    cloud_worker.get_connection_name    ${log_type}
    ...    product_type=${product_type}    bts_index=${bts_index}    cudu_index=${cudu_index}
    cloud_worker.Start To Collect Bip Log
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    cudu_index=${cudu_index}
    ...    connection=${connection}
    ...    timeout=${timeout}
    ...    &{template_params}
    Log    ${dict_argument}

_CloudRAN.stop_and_download_bip_log
    [Arguments]    ${log_type}
    ...            ${product_type}=vdu
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${dict_argument}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to stop and download Bip Log. Bip log is only for vdu.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | log_type | Yes | bip, wireshark, tti, syslog, snapshot, etc. |
    ...    | product_type | Yes | vdu, vcu, classical |
    ...    | bts_index | Yes | The list index from tl.cu[]  |
    ...    | cudu_index | Yes | the index of cu, du or classical bts  |
    ...    | dict_argument | No |  { dcap_server: {host: x, username: x, password: x, port: x}, argument: {} } |
    ...    | timeout | No |    |
    ...    *Example:*
    ...        - _CloudRAN.start_bip_log
    ...
    should be true    '${product_type}'=='vdu'
    ${template_params}=    _CloudRAN.prepare_bip_template_params    log_type=${log_type}
    Remove From Dictionary    ${template_params}    port_name
    ${connection}=    cloud_worker.get_connection_name    ${log_type}
    ...    product_type=${product_type}    bts_index=${bts_index}    cudu_index=${cudu_index}
    ${local_file_path}=    cloud_worker.Stop and Download Bip Log
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    cudu_index=${cudu_index}
    ...    connection=${connection}
    ...    timeout=${timeout}
    ...    &{template_params}
    _CloudRAN.create_yaml_file_with_metadata
    ...            ${log_type}
    ...            ${product_type}
    ...            ${bts_index}
    ...            ${cudu_index}
    ...            ${local_file_path}
    ...            ${timeout}
    Log    ${dict_argument}
    [Return]   ${local_file_path}

_CloudRAN.start_tti_log
    [Arguments]    ${log_type}
    ...            ${product_type}=vdu
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${dict_argument}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to start to collect ttitrace Log.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | log_type | Yes | bip, wireshark, tti, syslog, snapshot, etc. |
    ...    | product_type | Yes | vdu, vcu, classical |
    ...    | bts_index | Yes | The list index from tl.cu[]  |
    ...    | cudu_index | Yes | the index of cu, du or classical bts  |
    ...    | dict_argument | No |  { dcap_server: {host: x, username: x, password: x, port: x}, argument: {} } |
    ...    | timeout | No |    |
    ...    *Example:*
    ...        - _CloudRAN.start_tti_log
    ...
    should be true    '${product_type}'=='vdu'
    ${trace_info}=    _CloudRAN.prepare_tti_template_params    log_type=${log_type}
    ${dcap_info}=    _CommonBTS.prepare_dcap_server_from_dict_params    ${dict_argument}
    ${trace_id}=    common_worker.Start To Collect Log By DCAP
    ...    ${dcap_info}        ${log_type}
    ...    product_type=vdu    bts_index=${bts_index}    cudu_index=${cudu_index}
    ...    &{trace_info}
    Log    ${timeout}
    [Return]    ${trace_id}

_CloudRAN.stop_and_download_tti_log
    [Arguments]    ${log_type}
    ...            ${product_type}=vdu
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${dict_argument}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to stop and download tti Log.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | log_type | Yes | bip, wireshark, tti, syslog, snapshot, etc. |
    ...    | product_type | Yes | vdu, vcu, classical |
    ...    | bts_index | Yes | The list index from tl.cu[]  |
    ...    | cudu_index | Yes | the index of cu, du or classical bts  |
    ...    | dict_argument | No |  { dcap_server: {host: x, username: x, password: x, port: x}, argument: {} } |
    ...    | timeout | No |    |
    ...    *Example:*
    ...        - _CloudRAN.stop_and_download_tti_log
    ...
    should be true    '${product_type}'=='vdu'
    ${local_file_path}=    common_worker.Stop and Download Log By DCAP
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    cudu_index=${cudu_index}
    _CloudRAN.create_yaml_file_with_metadata
    ...            ${log_type}
    ...            ${product_type}
    ...            ${bts_index}
    ...            ${cudu_index}
    ...            ${local_file_path}
    ...            ${timeout}
    Log    ${dict_argument}
    [Return]   ${local_file_path}

_CloudRAN.start_event_based_L1_IQ_log
    [Arguments]    ${log_type}
    ...            ${product_type}
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${dict_argument}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to start to collect vdu event based L1 IQ Log.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | log_type | Yes | tti |
    ...    | product_type | Yes | gnb, enb |
    ...    | bts_index | Yes | The list index from gnbs or enbs  |
    ...    | cudu_index | Yes | the index of classical bts  |
    ...    | dict_argument | No |  { dcap_server: {host: x, username: x, password: x, port: x}, argument: {} } |
    ...    | timeout | No |    |
    ...    *Example:*
    ...        - _CloudRAN.start_event_based_L1_IQ_log
    ...
    should be true    '${product_type}'=='vdu'
    ${trace_info_template}=    _CommonBTS.prepare_template_params    ${log_type}    ${CLOUDRAN_TEMPLATE_PATH}
    Set To Dictionary    ${trace_info_template}    gnb_trace_profile=${NONE}

    ${argument}=    _CommonBTS.prepare_dcap_argument_from_dict_params    ${dict_argument}
    &{trace_info_argument}=    Create Dictionary    vdu_event_based_tracer=${argument["vdu_event_based_tracer"]}

    ${dcap_info}=    _CommonBTS.prepare_dcap_server_from_dict_params    ${dict_argument}
    ${trace_id}=    common_worker.Start To Collect Log By DCAP
    ...    ${dcap_info}        ${log_type}
    ...    product_type=${product_type}    bts_index=${bts_index}    cudu_index=${cudu_index}
    ...    &{trace_info_template}    &{trace_info_argument}
    Log    ${timeout}
    [Return]    ${trace_id}

_CloudRAN.stop_and_download_event_based_L1_IQ_log
    [Arguments]    ${log_type}
    ...            ${product_type}
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${dict_argument}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to stop and download vdu event based L1 IQ Log.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | log_type | Yes | bip, wireshark, tti, syslog, snapshot, etc. |
    ...    | product_type | Yes | vdu, vcu, classical |
    ...    | bts_index | Yes | The list index from tl.cu[]  |
    ...    | cudu_index | Yes | the index of cu, du or classical bts  |
    ...    | dict_argument | No |  { dcap_server: {host: x, username: x, password: x, port: x}, argument: {} } |
    ...    | timeout | No |    |
    ...    *Example:*
    ...        - _CloudRAN.stop_and_download_event_based_L1_IQ_log
    ...
    Log    ${log_type}
    Log    ${timeout}
    ${wait_stop_time}=    utility.check_nested_attributes    ${dict_argument}    argument.wait_stop_time
    ${check_interval}=    utility.check_nested_attributes    ${dict_argument}    argument.check_interval
    ${local_file_path}=    common_worker.Wait For Trace and Download Log By DCAP
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    cudu_index=${cudu_index}
    ...    wait_stop_time=${wait_stop_time}
    ...    check_interval=${check_interval}
    [Return]   ${local_file_path}

_CloudRAN.start_L1_IQ_log
    [Arguments]    ${log_type}
    ...            ${product_type}
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${dict_argument}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to start to collect vdu L1 IQ Log.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | log_type | Yes | tti |
    ...    | product_type | Yes | gnb, enb |
    ...    | bts_index | Yes | The list index from gnbs or enbs  |
    ...    | cudu_index | Yes | the index of classical bts  |
    ...    | dict_argument | No |  { dcap_server: {host: x, username: x, password: x, port: x}, argument: {} } |
    ...    | timeout | No |    |
    ...    *Example:*
    ...        - _CloudRAN.start_L1_IQ_log
    ...
    should be true    '${product_type}'=='vdu'
    ${trace_info_template}=    _CommonBTS.prepare_template_params    ${log_type}    ${CLOUDRAN_TEMPLATE_PATH}
    Set To Dictionary    ${trace_info_template}    gnb_trace_profile=${NONE}

    ${dcap_info}=    _CommonBTS.prepare_dcap_server_from_dict_params    ${dict_argument}
    ${trace_id}=    common_worker.Start To Collect Log By DCAP
    ...    ${dcap_info}        ${log_type}
    ...    product_type=${product_type}    bts_index=${bts_index}    cudu_index=${cudu_index}
    ...    &{trace_info_template}
    Log    ${timeout}
    [Return]    ${trace_id}

_CloudRAN.stop_and_download_L1_IQ_log
    [Arguments]    ${log_type}
    ...            ${product_type}
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${dict_argument}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to stop and download vdu L1 IQ Log.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | log_type | Yes | bip, wireshark, tti, syslog, snapshot, etc. |
    ...    | product_type | Yes | vdu, vcu, classical |
    ...    | bts_index | Yes | The list index from tl.cu[]  |
    ...    | cudu_index | Yes | the index of cu, du or classical bts  |
    ...    | dict_argument | No |  { dcap_server: {host: x, username: x, password: x, port: x}, argument: {} } |
    ...    | timeout | No |    |
    ...    *Example:*
    ...        - _CloudRAN.stop_and_download_L1_IQ_log
    ...
    Log    ${log_type}
    Log    ${timeout}
    ${wait_stop_time}=    utility.check_nested_attributes    ${dict_argument}    argument.wait_stop_time
    ${check_interval}=    utility.check_nested_attributes    ${dict_argument}    argument.check_interval
    ${local_file_path}=    common_worker.Wait For Trace and Download Log By DCAP
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    cudu_index=${cudu_index}
    ...    wait_stop_time=${wait_stop_time}
    ...    check_interval=${check_interval}
    [Return]   ${local_file_path}

_CloudRAN.start_syslog_log
    [Arguments]    ${log_type}
    ...            ${product_type}=vdu
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${dict_argument}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to start to collect syslog.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | log_type | Yes | bip, wireshark, tti, syslog, snapshot, etc. |
    ...    | product_type | Yes | vdu, vcu, classical |
    ...    | bts_index | Yes | The list index from tl.cu[]  |
    ...    | cudu_index | Yes | the index of cu, du or classical bts  |
    ...    | dict_argument | No |  { dcap_server: {host: x, username: x, password: x, port: x}, argument: {} } |
    ...    | timeout | No |    |
    ...    *Example:*
    ...        - _CloudRAN.start_syslog_log
    ...
    Log    ${dict_argument}
    ${connection}=    cloud_worker.get_connection_name    ${log_type}
    ...    product_type=${product_type}    bts_index=${bts_index}    cudu_index=${cudu_index}
    ${local_file_path}=    cloud_worker.Start To Collect Syslog Log
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    cudu_index=${cudu_index}
    ...    connection=${connection}
    ...    timeout=${timeout}
    [Return]    ${local_file_path}

_CloudRAN.start_snapshot_log
    [Arguments]    ${log_type}
    ...            ${product_type}=vdu
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${dict_argument}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to start to collect snapshot from vdu or vcu.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | log_type | Yes | bip, wireshark, tti, syslog, snapshot, etc. |
    ...    | product_type | Yes | vdu, vcu, classical |
    ...    | bts_index | Yes | The list index from tl.cu[]  |
    ...    | cudu_index | Yes | the index of cu, du or classical bts  |
    ...    | dict_argument | No |  { dcap_server: {host: x, username: x, password: x, port: x}, argument: {} } |
    ...    | timeout | No |    |
    ...    *Example:*
    ...        - _CloudRAN.start_snapshot_log
    ...
    Log    ${dict_argument}
    ${connection}=    cloud_worker.get_connection_name    ${log_type}
    ...    product_type=${product_type}    bts_index=${bts_index}    cudu_index=${cudu_index}
    ${local_file_path}=    Run Keyword    cloud_worker.Start To Collect ${product_type} Snapshot Log
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    cudu_index=${cudu_index}
    ...    connection=${connection}
    ...    timeout=${timeout}
    [Return]    ${local_file_path}


################################ Prepare template parameters #################################
_CloudRAN.prepare_wireshark_template_params
    [Arguments]    ${log_type}=wireshark_cp
    ...            ${product_type}=vdu
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to prepare wireshark template parameters.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | log_type | Yes | bip, wireshark, tti, syslog, snapshot, etc. |
    ...    | product_type | Yes | vdu, vcu, classical |
    ...    *Example:*
    ...        - _CloudRAN.prepare_wireshark_template_params
    ...
    ${key_chain}=    create list    log_params    ${log_type}    ${product_type}
    ${template_params}=    _CommonBTS.get_params_from_template    ${key_chain}    ${CLOUDRAN_TEMPLATE_PATH}
    [Return]    ${template_params}

_CloudRAN.prepare_bip_template_params
    [Arguments]    ${log_type}=bip
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to prepare bip template parameters.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | log_type | Yes | bip, wireshark, tti, syslog, snapshot, etc. |
    ...    *Example:*
    ...        - _CloudRAN.prepare_bip_template_params
    ...
    ${template_params}=    _CommonBTS.prepare_template_params    ${log_type}    ${CLOUDRAN_TEMPLATE_PATH}
    [Return]    ${template_params}

_CloudRAN.prepare_tti_template_params
    [Arguments]    ${log_type}=tti
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to prepare tti template parameters.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | log_type | Yes | bip, wireshark, tti, syslog, snapshot, etc. |
    ...    *Example:*
    ...        - _CloudRAN.prepare_tti_template_params
    ...
    ${template_params}=    _CommonBTS.prepare_template_params    ${log_type}    ${CLOUDRAN_TEMPLATE_PATH}
    [Return]    ${template_params}


################################ Validate product indices #################################
_CloudRAN.validate_product_indices
    [Arguments]    ${product_type}
    ...            ${bts_index}
    ...            ${cudu_index}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to validate if the gnb/vcu/vdu indices exceed the limit.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | product_type | Yes | vdu, vcu, classical |
    ...    | bts_index | Yes | The list index from tl.cu[] |
    ...    | cudu_index | Yes | the index of cu, du or classical bts |
    ...    *Example:*
    ...        - _CloudRAN.validate_product_indices
    ...
    _CloudRAN.validate_gnb_index     ${bts_index}
    _CloudRAN.validate_cudu_index    ${product_type}    ${bts_index}    ${cudu_index}

_CloudRAN.validate_gnb_index
    [Arguments]    ${bts_index}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to validate if the gnb index exceeds the limit.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | bts_index | Yes | The list index from tl.cu[] |
    ...    *Example:*
    ...        - _CloudRAN.validate_gnb_index
    ...
    ${length}=    Get Length    ${tl.gnbs}
    ${max_index}=    Evaluate    ${length} - 1
    Should Be True    ${max_index} >= ${bts_index} and ${bts_index} >= 0

_CloudRAN.validate_cudu_index
    [Arguments]    ${product_type}
    ...            ${bts_index}
    ...            ${cudu_index}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to if the vcu/vdu index exceeds the limit.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | product_type | Yes | vdu, vcu, classical |
    ...    | bts_index | Yes | The list index from tl.cu[] |
    ...    | cudu_index | Yes | the index of cu, du or classical bts |
    ...    *Example:*
    ...        - _CloudRAN.validate_cudu_index
    ...
    Run Keyword If    '${product_type}' == 'vcu'    Should Be True    ${cudu_index} == 0
    ${vdu_length}=    Run Keyword If    '${product_type}' == 'vdu'    Get Length    ${tl.gnbs[${bts_index}].dus}
    ${max_index}=    Run Keyword If    '${product_type}' == 'vdu'    Evaluate    ${vdu_length} - 1
    Run Keyword If    '${product_type}' == 'vdu'
    ...    Should Be True    ${max_index} >= ${cudu_index} and ${cudu_index} >= 0

_CloudRAN.create_yaml_file_with_metadata
    [Arguments]    ${log_type}
    ...            ${product_type}
    ...            ${bts_index}
    ...            ${cudu_index}
    ...            ${log_path}
    ...            ${timeout}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to create a yaml file with required metadata.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | log_type | Yes | bip, wireshark, tti, syslog, snapshot, etc. |
    ...    | product_type | Yes | vdu, vcu, classical |
    ...    | bts_index | Yes | The list index from tl.cu[]  |
    ...    | cudu_index | Yes | the index of cu, du or classical bts  |
    ...    | log_path | No |    |
    ...    | timeout | No |    |
    ...    *Example:*
    ...        - _CloudRAN.create_yaml_file_with_metadata
    ...
    ${log_directory}=    metadata.get log directory    ${log_path}
    ${file_path}=    Catenate    SEPARATOR=    ${log_directory}    /log_metadata.yml

    ${connection}=    cloud_worker.get_connection_name    ${log_type}
    ...    product_type=${product_type}    bts_index=${bts_index}    cudu_index=${cudu_index}
    ${bts_version}=    cloud_worker.Get BTS Active Software Version    ${product_type}    ${bts_index}    ${cudu_index}
    ...    ${connection}    ${timeout}

    ${content}=    Create Dictionary    product_type=${product_type}    bts_version=${bts_version}
    utility.create_yaml_file    ${file_path}    ${content}
    [Return]   ${file_path}

_CloudRAN.start_collection_profile_log
    [Arguments]    ${log_type}
    ...            ${product_type}=vdu
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${dict_argument}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Author:*
    ...        - liang.xiang@nokia-sbell.com

    Run Keyword If    '+' in '${log_type}'    Run Keyword
    ...    _CommonBTS.Check And Lookup Values    ${log_type}    ${product_type}    ${dict_argument}    profile_argument
    ${argument}=    _CommonBTS.prepare_dcap_argument_from_dict_params    ${dict_argument}
    ${profile_argument}=    _CommonBTS.prepare_dcap_argument_from_dict_params    ${dict_argument}    profile_argument
    ${dcap_info}=   _CommonBTS.prepare_dcap_server_from_dict_params    ${dict_argument}
    ${trace_id}=    common_worker.Start To Collect Log By DCAP
    ...    ${dcap_info}        ${log_type}
    ...    product_type=${product_type}    cell_info=${argument}    bts_index=${bts_index}    cudu_index=${cudu_index}
    ...    &{profile_argument}
    Log    ${timeout}
    [Return]    ${trace_id}

_CloudRAN.stop_and_download_collection_profile_log
    [Arguments]    ${log_type}
    ...            ${product_type}=gnb
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${dict_argument}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Author:*
    ...        - liang.xiang@nokia-sbell.com

    ${local_file_path}=    common_worker.Stop and Download Log By DCAP
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    cudu_index=${cudu_index}
    _CloudRAN.create_yaml_file_with_metadata
    ...            ${log_type}
    ...            ${product_type}
    ...            ${bts_index}
    ...            ${cudu_index}
    ...            ${local_file_path}
    ...            ${timeout}
    Log    ${dict_argument}
    [Return]   ${local_file_path}

_CloudRAN.start_ip_traffic_log
    [Arguments]    ${log_type}
    ...            ${product_type}=vdu
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${dict_argument}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Author:*
    ...        - liang.xiang@nokia-sbell.com
    ${connection}=    cloud_worker.get_connection_name    ${log_type}
    ...    product_type=${product_type}    bts_index=${bts_index}    cudu_index=${cudu_index}

    ${local_file_path}=    Run Keyword    cloud_worker.Start To Collect ${product_type} ip_traffic Log
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    cudu_index=${cudu_index}
    ...    connection=${connection}
    ...    timeout=${timeout}
    ...    &{dict_argument}

_CloudRAN.stop_and_download_ip_traffic_log
    [Arguments]    ${log_type}
    ...            ${product_type}=vdu
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${dict_argument}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Author:*
    ...        - liang.xiang@nokia-sbell.com

    ${local_file_path}=    Run Keyword    cloud_worker.Stop To Collect ${product_type} ip_traffic Log
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    cudu_index=${cudu_index}
    ...    &{dict_argument}
    _CloudRAN.create_yaml_file_with_metadata
    ...            ${log_type}
    ...            ${product_type}
    ...            ${bts_index}
    ...            ${cudu_index}
    ...            ${local_file_path}
    ...            ${timeout}
    RETURN   ${local_file_path}

_CloudRAN.start_k8s_log
    [Arguments]    ${log_type}
    ...            ${product_type}=vdu
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${dict_argument}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Author:*
    ...        - liang.xiang@nokia-sbell.com
    ${connection}=    cloud_worker.get_connection_name    ${log_type}
    ...    product_type=${product_type}    bts_index=${bts_index}    cudu_index=${cudu_index}
    ${local_file_path}=    cloud_worker.Start To Collect k8s Log
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    cudu_index=${cudu_index}
    ...    connection=${connection}
    ...    timeout=${timeout}
    ...    &{dict_argument}
    RETURN    ${local_file_path}

_CloudRAN.start_emil_log
    [Arguments]    ${log_type}
    ...            ${product_type}=vdu
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${dict_argument}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to start to collect emil Log.
    ...    *Author:*
    ...        - liang.xiang@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | log_type | Yes | emil |
    ...    | product_type | Yes | gnb, enb |
    ...    | bts_index | Yes | The list index from gnbs or enbs  |
    ...    | cudu_index | Yes | the index of classical bts  |
    ...    | dict_argument | No |  { dcap_server: {host: x, username: x, password: x, port: x}, argument: {} } |
    ...    | timeout | No |    |
    ...    *Example:*
    ...        - _CloudRAN.start_emil_log
    ...
    ${argument}=    _CommonBTS.prepare_dcap_argument_from_dict_params    ${dict_argument}
    ${dcap_info}=    _CommonBTS.prepare_dcap_server_from_dict_params    ${dict_argument}
    ${trace_info}=    _CloudRAN.prepare_wireshark_template_params
    ...    log_type=${log_type}
    ...    product_type=${product_type}

    ${trace_id}=    common_worker.Start To Collect Log By DCAP
    ...    ${dcap_info}        ${log_type}
    ...    product_type=${product_type}    cell_info=${argument}    bts_index=${bts_index}    cudu_index=${cudu_index}
    ...    &{trace_info}
    Log    ${timeout}
    RETURN    ${trace_id}

_CloudRAN.stop_and_download_emil_log
    [Arguments]    ${log_type}
    ...            ${product_type}=vdu
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${dict_argument}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to stop and download emil Log.
    ...    *Author:*
    ...        - liang.xiang@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | log_type | Yes | bip, wireshark, tti, syslog, snapshot, etc. |
    ...    | product_type | Yes | vdu, vcu, classical |
    ...    | bts_index | Yes | The list index from tl.cu[]  |
    ...    | cudu_index | Yes | the index of cu, du or classical bts  |
    ...    | dict_argument | No |  { dcap_server: {host: x, username: x, password: x, port: x}, argument: {} } |
    ...    | timeout | No |    |
    ...    *Example:*
    ...        - _CloudRAN.stop_and_download_emil_log
    ...

    ${local_file_path}=    common_worker.Stop and Download Log By DCAP
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    cudu_index=${cudu_index}
    _CloudRAN.create_yaml_file_with_metadata
    ...            ${log_type}
    ...            ${product_type}
    ...            ${bts_index}
    ...            ${cudu_index}
    ...            ${local_file_path}
    ...            ${timeout}
    Log    ${dict_argument}
    RETURN   ${local_file_path}

_CloudRAN.start_cell_trace_log
    [Arguments]    ${log_type}
    ...            ${product_type}=vdu
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${dict_argument}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to start to collect emil Log.
    ...    *Author:*
    ...        - liang.xiang@nokia-sbell.com

    ${argument}=    _CommonBTS.prepare_dcap_argument_from_dict_params    ${dict_argument}
    ${dcap_info}=    _CommonBTS.prepare_dcap_server_from_dict_params    ${dict_argument}
    ${trace_info}=    _CloudRAN.prepare_wireshark_template_params
    ...    log_type=${log_type}
    ...    product_type=${product_type}

    ${trace_id}=    common_worker.Start To Collect Log By DCAP
    ...    ${dcap_info}        ${log_type}
    ...    product_type=${product_type}    cell_info=${argument}    bts_index=${bts_index}    cudu_index=${cudu_index}
    ...    &{trace_info}
    Log    ${timeout}
    RETURN    ${trace_id}

_CloudRAN.stop_and_download_cell_trace_log
    [Arguments]    ${log_type}
    ...            ${product_type}=vdu
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${dict_argument}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to stop and download emil Log.
    ...    *Author:*
    ...        - liang.xiang@nokia-sbell.com

    ${local_file_path}=    common_worker.Stop and Download Log By DCAP
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    cudu_index=${cudu_index}
    _CloudRAN.create_yaml_file_with_metadata
    ...            ${log_type}
    ...            ${product_type}
    ...            ${bts_index}
    ...            ${cudu_index}
    ...            ${local_file_path}
    ...            ${timeout}
    Log    ${dict_argument}
    RETURN   ${local_file_path}
