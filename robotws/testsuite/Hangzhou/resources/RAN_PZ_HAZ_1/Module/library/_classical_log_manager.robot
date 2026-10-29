*** Settings ***
Documentation
...    Author: Liu, Renhui
...    Contact: renhui-david.liu@nokia-sbell.com
...    Theese KWs should be unexposed to user. It is internally used to collect logs for classical bts.


Library           Collections
Library           DateTime
Library           OperatingSystem
Library           Process
Library           String
Library           yaml
Library           json
Resource          log_worker/classical_log_worker.robot


*** Variables ***
#${TEMPLATE_PATH}    ${CURDIR}/../config/log_parameters_template.yml
&{gnb_log_type_dict}    emil=cp_5g    tti=L2Ps_Component    cell_trace=Tracer_5g
...                     syslog=condor5gSyslog    bip=bip_interface_mirroring
&{enb_log_type_dict}    emil=cp_4g    tti=condor4gTti    cell_trace=lteTracer_4g    syslog=condor4gSyslog

*** Keywords ***
_ClassicalBTS.start_syslog_log
    [Arguments]    ${log_type}
    ...            ${product_type}
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
    log    ${cudu_index}
    log    ${dict_argument}
    ${connection}=    classical_worker.get_connection_name    ${log_type}    ${product_type}    bts_index=${bts_index}
    ${local_file_path}=    classical_worker.Start To Collect Syslog Log
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    connection=${connection}
    ...    timeout=${timeout}
    [Return]    ${local_file_path}

_ClassicalBTS.stop_and_download_syslog_log
    [Arguments]    ${log_type}
    ...            ${product_type}
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${dict_argument}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to stop and download syslog.
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
    ...        - _ClassicalBTS.stop_and_download_syslog_log
    ...
    log    ${cudu_index}
    log    ${dict_argument}
    log    ${timeout}
    ${connection}=    classical_worker.get_connection_name    ${log_type}    ${product_type}    bts_index=${bts_index}
    ${local_file_dir}=    classical_worker.Stop and Download Syslog Log    ${connection}
    [Return]   ${local_file_dir}

_ClassicalBTS.start_snapshot_log
    [Arguments]    ${log_type}
    ...            ${product_type}
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${dict_argument}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to start to collect snapshot from classical bts.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | log_type | Yes | snapshot |
    ...    | product_type | Yes | gnb, enb |
    ...    | bts_index | Yes | The list index from tl.cu[]  |
    ...    | cudu_index | Yes | the index of cu, du or classical bts  |
    ...    | dict_argument | No |  { dcap_server: {host: x, username: x, password: x, port: x}, argument: {} } |
    ...    | timeout | No |    |
    ...    *Example:*
    ...        - _ClassicalBTS.start_snapshot_log
    ...
    log    ${cudu_index}
    log    ${dict_argument}
    ${connection}=    classical_worker.get_connection_name    ${log_type}    ${product_type}    bts_index=${bts_index}
    ${local_file_dir}=    Run Keyword    classical_worker.Start To Collect Snapshot Log
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    connection=${connection}
    ...    timeout=${timeout}
    [Return]    ${local_file_dir}

_ClassicalBTS.start_bip_log
    [Arguments]    ${log_type}
    ...            ${product_type}=gnb
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${dict_argument}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to start to collect bip Log.
    ...
    log    ${bts_index}
    log    ${cudu_index}
    log    ${timeout}
    should be true    '${product_type}'!='enb'
    ${argument}=    _CommonBTS.prepare_dcap_argument_from_dict_params    ${dict_argument}
    ${trace_info}=    _CommonBTS.prepare_template_params    ${log_type}    ${CLASSICAL_TEMPLATE_PATH}
    ${dcap_info}=    _CommonBTS.prepare_dcap_server_from_dict_params    ${dict_argument}
    ${trace_id}=    common_worker.Start To Collect Log By DCAP
    ...    ${dcap_info}        ${log_type}
    ...    product_type=${product_type}    cell_info=${argument}    bts_index=${0}    cudu_index=${0}
    ...    &{trace_info}
    [Return]    ${trace_id}

_ClassicalBTS.stop_and_download_bip_log
    [Arguments]    ${log_type}
    ...            ${product_type}=gnb
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${dict_argument}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to stop and download bip Log.
    ...
    log    ${dict_argument}
    should be true    '${product_type}'!='enb'
    ${local_file_path}=    common_worker.Stop and Download Log By DCAP
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    cudu_index=${cudu_index}
    _ClassicalBTS.create_yaml_file_with_metadata
    ...            ${log_type}
    ...            ${product_type}
    ...            ${bts_index}
    ...            ${cudu_index}
    ...            ${local_file_path}
    ...            ${timeout}
    [Return]   ${local_file_path}

_ClassicalBTS.start_tti_log
    [Arguments]    ${log_type}
    ...            ${product_type}=gnb
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${dict_argument}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to start to collect ttitrace Log.
    ...
    should be true    '${product_type}'!='enb'
    ${argument}=    _CommonBTS.prepare_dcap_argument_from_dict_params    ${dict_argument}
    ${trace_info}=    _CommonBTS.prepare_template_params    ${log_type}    ${CLASSICAL_TEMPLATE_PATH}
    ${dcap_info}=    _CommonBTS.prepare_dcap_server_from_dict_params    ${dict_argument}
    ${trace_id}=    common_worker.Start To Collect Log By DCAP
    ...    ${dcap_info}        ${log_type}
    ...    product_type=${product_type}    cell_info=${argument}    bts_index=${bts_index}    cudu_index=${cudu_index}
    ...    &{trace_info}
    log    ${timeout}
    [Return]    ${trace_id}

_ClassicalBTS.stop_and_download_tti_log
    [Arguments]    ${log_type}
    ...            ${product_type}=gnb
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${dict_argument}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to stop and download tti Log.
    ...
    log    ${dict_argument}
    should be true    '${product_type}'!='enb'
    ${local_file_path}=    common_worker.Stop and Download Log By DCAP
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    cudu_index=${cudu_index}
    _ClassicalBTS.create_yaml_file_with_metadata
    ...            ${log_type}
    ...            ${product_type}
    ...            ${bts_index}
    ...            ${cudu_index}
    ...            ${local_file_path}
    ...            ${timeout}
    [Return]   ${local_file_path}

_ClassicalBTS.start_wireshark_log
    [Arguments]    ${log_type}
    ...            ${product_type}
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${dict_argument}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to start to collect wireshark log.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | log_type | Yes | snapshot |
    ...    | product_type | Yes | gnb, enb |
    ...    | bts_index | Yes | The list index from tl.cu[]  |
    ...    | cudu_index | Yes | the index of cu, du or classical bts  |
    ...    | dict_argument | No |  { dcap_server: {host: x, username: x, password: x, port: x}, argument: {} } |
    ...    | timeout | No |    |
    ...    *Example:*
    ...        - _ClassicalBTS.start_wireshark_log
    ...
    log    ${cudu_index}
    ${options}=    _ClassicalBTS.prepare_wireshark_options_from_dict_params    ${dict_argument}
    ${options_upper}=    Convert To Uppercase    ${options}
    ${wireshark_options}    Set Variable If    '${options_upper}' == 'NONE'    -i any    ${options}

    ${connection}=    classical_worker.get_connection_name    ${log_type}    ${product_type}    bts_index=${bts_index}
    classical_worker.Start To Collect Wireshark Log
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    connection=${connection}
    ...    wireshark_options=${wireshark_options}
    ...    timeout=${timeout}

_ClassicalBTS.stop_and_download_wireshark_log
    [Arguments]    ${log_type}
    ...            ${product_type}
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
    ...        - _ClassicalBTS.stop_and_download_wireshark_log
    ...
    log    ${cudu_index}
    log    ${dict_argument}
    log    ${timeout}
    ${connection}=    classical_worker.get_connection_name    ${log_type}    ${product_type}    bts_index=${bts_index}
    ${local_file_path}=    classical_worker.Stop and Download Wireshark Log    ${connection}
    [Return]   ${local_file_path}


################################ Prepare template parameters #################################
_ClassicalBTS.prepare_tti_options_from_dict_params
    [Arguments]    ${dict_argument}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to prepare tti options.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | dict_argument | Yes |  |
    ...    *Example:*
    ...        - _ClassicalBTS.prepare_tti_options_from_dict_params
    ...
    [Return]    ${dict_argument["argument"]["tti_options"]}

_ClassicalBTS.prepare_log_template_params
    [Arguments]    ${log_type}=tti
    ...            ${product_type}=gnb
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to prepare tti template parameters.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | log_type | Yes | tti |
    ...    *Example:*
    ...        - _ClassicalBTS.prepare_log_template_params
    ...
    ${key_chain}=    create list    log_params    ${log_type}    ${product_type}
    ${template_params}=    _CommonBTS.get_params_from_template    ${key_chain}    ${CLASSICAL_TEMPLATE_PATH}
    [Return]    ${template_params}


################################ Prepare dict parameters #################################
_ClassicalBTS.prepare_bip_options_from_dict_params
    [Arguments]    ${dict_argument}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to prepare bip options.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | dict_argument | Yes | { dcap_server: {host: x, username: x, password: x, port: x}, argument: {} } |
    ...    *Example:*
    ...        - _ClassicalBTS.prepare_bip_options_from_dict_params
    ...
    [Return]    ${dict_argument["argument"]["bip_options"]}

_ClassicalBTS.prepare_wireshark_options_from_dict_params
    [Arguments]    ${dict_argument}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to prepare wireshark_ options.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | dict_argument | Yes | { dcap_server: {host: x, username: x, password: x, port: x}, argument: {} } |
    ...    *Example:*
    ...        - _ClassicalBTS.prepare_wireshark_options_from_dict_params
    ...
    ${wireshark_options}=    utility.check_nested_attributes    ${dict_argument}    argument.wireshark_options
    [Return]    ${wireshark_options}


################################ Validate product indices #################################
_ClassicalBTS.validate_product_indices
    [Arguments]    ${product_type}
    ...            ${bts_index}
    ...            ${cudu_index}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to validate if the gnb/enb indices exceed the limit.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | product_type | Yes | vdu, vcu, classical |
    ...    | bts_index | Yes | The list index from tl.cu[] |
    ...    | cudu_index | Yes | the index of cu, du or classical bts |
    ...    *Example:*
    ...        - _ClassicalBTS.validate_product_indices
    ...
    log    ${cudu_index}
    Run Keyword If    '${product_type}' == 'gnb'
    ...    _ClassicalBTS.validate_gnb_index     ${bts_index}
    ...    ELSE IF    '${product_type}' == 'enb'
    ...    _ClassicalBTS.validate_enb_index     ${bts_index}

_ClassicalBTS.validate_gnb_index
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
    ...        - _ClassicalBTS.validate_gnb_index
    ...
    ${length}=    Get Length    ${tl.gnbs}
    ${max_index}=    Evaluate    ${length} - 1
    Should Be True    ${max_index} >= ${bts_index} and ${bts_index} >= 0

_ClassicalBTS.validate_enb_index
    [Arguments]    ${bts_index}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to if the enb index exceeds the limit.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | product_type | Yes | vdu, vcu, classical |
    ...    | bts_index | Yes | The list index from tl.cu[] |
    ...    | cudu_index | Yes | the index of cu, du or classical bts |
    ...    *Example:*
    ...        - _ClassicalBTS.validate_enb_index
    ...
    ${length}=    Get Length    ${tl.enbs}
    ${max_index}=    Evaluate    ${length} - 1
    Should Be True    ${max_index} >= ${bts_index} and ${bts_index} >= 0

_ClassicalBTS.create_yaml_file_with_metadata
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
    ...        - _ClassicalBTS.create_yaml_file_with_metadata
    ...
    ${log_directory}=    metadata.get log directory    ${log_path}
    ${file_path}=    Catenate    SEPARATOR=    ${log_directory}    /log_metadata.yml

    ${connection}=    classical_worker.get_connection_name    ${log_type}    ${product_type}    bts_index=${bts_index}
    ${bts_version}=    classical_worker.Get BTS Active Software Version    ${product_type}
    ...    ${bts_index}    ${cudu_index}    ${connection}    ${timeout}

    ${content}=    Create Dictionary    product_type=${product_type}    bts_version=${bts_version}
    utility.create_yaml_file    ${file_path}    ${content}
    [Return]   ${file_path}

_ClassicalBTS.start_emil_log
    [Arguments]    ${log_type}
    ...            ${product_type}=gnb
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
    ...        - _ClassicalBTS.start_emil_log
    ...
    log    ${timeout}
    ${trace_info}=    _ClassicalBTS.prepare_log_template_params
    ...    log_type=${log_type}
    ...    product_type=${product_type}
    Set To Dictionary    ${trace_info}    gnb_trace_profile=${NONE}

    ${dcap_info}=    _CommonBTS.prepare_dcap_server_from_dict_params    ${dict_argument}
    ${trace_id}=    common_worker.Start To Collect Log By DCAP
    ...    ${dcap_info}        ${log_type}
    ...    product_type=${product_type}    bts_index=${bts_index}    cudu_index=${cudu_index}
    ...    &{trace_info}
    [Return]    ${trace_id}

_ClassicalBTS.stop_and_download_emil_log
    [Arguments]    ${log_type}
    ...            ${product_type}=gnb
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
    ...        - _ClassicalBTS.stop_and_download_emil_log
    ...
    log    ${dict_argument}
    ${local_file_path}=    common_worker.Stop and Download Log By DCAP
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    cudu_index=${cudu_index}
    _ClassicalBTS.create_yaml_file_with_metadata
    ...            ${log_type}
    ...            ${product_type}
    ...            ${bts_index}
    ...            ${cudu_index}
    ...            ${local_file_path}
    ...            ${timeout}
    [Return]   ${local_file_path}

_ClassicalBTS.start_muti_emil_log
    [Arguments]    ${log_type}
    ...            ${product_type}=gnb
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${dict_argument}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to start to collect muti emil Log.
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
    ...        - _ClassicalBTS.start_muti_emil_log
    ...
    log    ${cudu_index}
    log    ${timeout}
    ${bts1_cell}=    _CommonBTS.prepare_dcap_argument_from_dict_params    ${dict_argument}    bts1_cell_argument
    ${bts2_cell}=    _CommonBTS.prepare_dcap_argument_from_dict_params    ${dict_argument}    bts2_cell_argument
    ${merged_cell_argument}   Create Dictionary    bts1_cell=&{bts1_cell}    bts2_cell=&{bts2_cell}
    ${dcap_info}=    _CommonBTS.prepare_dcap_server_from_dict_params    ${dict_argument}
    Run Keyword If    '${log_type}' == 'muti_emil'    Set Test Variable    ${log_type}	   emil
    ${trace_info}=    _ClassicalBTS.prepare_log_template_params
    ...    log_type=${log_type}

    ${trace_id}=    common_worker.Start To Collect Log By DCAP For MutiBTS
    ...    ${dcap_info}        ${log_type}
    ...    product_type=${product_type}    cell_info=${merged_cell_argument}
    ...    bts_index=${bts_index}    cudu_index=${0}
    ...    &{trace_info}
    [Return]    ${trace_id}

_ClassicalBTS.stop_and_download_muti_emil_log
    [Arguments]    ${log_type}=emil
    ...            ${product_type}=gnb
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${dict_argument}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to stop and download muti emil Log.
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
    ...        - _ClassicalBTS.stop_and_download_muti_emil_log
    ...
    log    ${log_type}
    ${local_file_path}=    _ClassicalBTS.stop_and_download_emil_log
    ...    emil
    ...    ${product_type}
    ...    ${bts_index}
    ...    ${cudu_index}
    ...    ${dict_argument}
    ...    ${timeout}
    [Return]   ${local_file_path}

_ClassicalBTS.start_collection_profile_log
    [Arguments]    ${log_type}
    ...            ${product_type}=gnb
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${dict_argument}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Author:*
    ...        - liang.xiang@nokia-sbell.com
    log    ${timeout}
    Run Keyword If    '+' in '${log_type}'    Run Keyword
    ...    _CommonBTS.Check And Lookup Values    ${log_type}    ${product_type}    ${dict_argument}    profile_argument
    ${argument}=    _CommonBTS.prepare_dcap_argument_from_dict_params    ${dict_argument}
    ${profile_argument}=    _CommonBTS.prepare_dcap_argument_from_dict_params    ${dict_argument}    profile_argument
    ${dcap_info}=   _CommonBTS.prepare_dcap_server_from_dict_params    ${dict_argument}
    ${trace_id}=    common_worker.Start To Collect Log By DCAP
    ...    ${dcap_info}        ${log_type}
    ...    product_type=${product_type}    cell_info=${argument}    bts_index=${bts_index}    cudu_index=${cudu_index}
    ...    &{profile_argument}
    [Return]    ${trace_id}

_ClassicalBTS.stop_and_download_collection_profile_log
    [Arguments]    ${log_type}
    ...            ${product_type}=gnb
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${dict_argument}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Author:*
    ...        - liang.xiang@nokia-sbell.com
    log    ${dict_argument}
    ${local_file_path}=    common_worker.Stop and Download Log By DCAP
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    cudu_index=${cudu_index}
    _ClassicalBTS.create_yaml_file_with_metadata
    ...            ${log_type}
    ...            ${product_type}
    ...            ${bts_index}
    ...            ${cudu_index}
    ...            ${local_file_path}
    ...            ${timeout}
    [Return]   ${local_file_path}

_ClassicalBTS.start_muti_collection_profile_log
    [Arguments]    ${log_type}
    ...            ${product_type}=gnb
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${dict_argument}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Author:*
    ...        - liang.xiang@nokia-sbell.com
    log    ${timeout}
    Run Keyword If    '+' in '${log_type}'    Run Keyword
    ...    _CommonBTS.Check And Lookup Values    ${log_type}    ${product_type}    ${dict_argument}    profile_argument
    ${profile_argument}=    _CommonBTS.prepare_dcap_argument_from_dict_params    ${dict_argument}    profile_argument
    ${duration}=    _CommonBTS.prepare_dcap_argument_from_dict_params    ${dict_argument}    duration
    ${trace_info}=    Create Dictionary    &{profile_argument}    duration=${duration}
    ${dcap_info}=   _CommonBTS.prepare_dcap_server_from_dict_params    ${dict_argument}

    ${bts1_cell}=    _CommonBTS.prepare_dcap_argument_from_dict_params    ${dict_argument}    bts1_cell_argument
    ${bts2_cell}=    _CommonBTS.prepare_dcap_argument_from_dict_params    ${dict_argument}    bts2_cell_argument
    ${merged_cell_argument}   Create Dictionary    bts1_cell=&{bts1_cell}    bts2_cell=&{bts2_cell}

    ${trace_id}=    common_worker.Start To Collect Log By DCAP For Muti Gnb
    ...    ${dcap_info}        ${log_type}
    ...    product_type=${product_type}    cell_info=${merged_cell_argument}
    ...    bts_index=${bts_index}    cudu_index=${cudu_index}
    ...    &{trace_info}
    [Return]    ${trace_id}

_ClassicalBTS.stop_and_download_muti_collection_profile_log
    [Arguments]    ${log_type}
    ...            ${product_type}=gnb
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${dict_argument}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Author:*
    ...        - liang.xiang@nokia-sbell.com
    log    ${dict_argument}
    ${local_file_path}=    common_worker.Stop and Download Log By DCAP
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    cudu_index=${cudu_index}
    _ClassicalBTS.create_yaml_file_with_metadata
    ...            ${log_type}
    ...            ${product_type}
    ...            ${bts_index}
    ...            ${cudu_index}
    ...            ${local_file_path}
    ...            ${timeout}
    [Return]   ${local_file_path}
