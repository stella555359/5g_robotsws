*** Settings ***
Documentation
...    Author: Liu, Renhui
...    Contact: renhui-david.liu@nokia-sbell.com


Library           dcap.py               WITH NAME    dcaper
Library           dcap_ute_controller.py        WITH NAME    utf_controller
#Library           emil.py    WITH NAME    emil
#Library           ../Cloud/python/basic.py    WITH NAME    basic
Library           String

*** Variables ***
@{vdu_tti_profile}    L2Ps_Component
${emil_host}   10.0.92.239
${emil_user}   yongkun.zhang
${emil_password}   Btstest@123
${emil_tool_path}  /cygdrive/c/Program Files/Emil
${emil_tool_win_path}  C:\\\\Program Files\\\\Emil
${emil_log_dir}  /cygdrive/c/emil_logs
${emil_log_win_dir}  C:\\\\emil_logs
${P_admin_console}              ${False}    # debug output to console


*** Keywords ***
common_dcap.Connect To DCAP
    [Arguments]    ${host}=10.56.221.45     ${port}=443    ${username}=dcapuser
    ...            ${password}=dcapadmin!    ${rd_version}=dcapv3
    ...            ${secure}=${True}    ${alias}=dcap
    [Documentation]    Used to connect to dcap server
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | host | yes | dcap server ip address  |
    ...    | port | yes | dcap server port  |
    ...    | username | no | user name to log in dcap server  |
    ...    | password | no | password to log in dcap server  |
    ...    | rd_version | no | dcap api version  |
    ...    | secure | no | true for https, false for http |
    ...    | alias | no | the instance alias |
    ...    | Return Value | Description |
    ...    Example
    ...    | Connect To DCAP | ${host} | ${port} |
    ...
    dcaper.connect_to_dcap    ${host}    ${port}
    ...                     username=${username}    password=${password}
    ...                     rd_version=${rd_version}
    ...                     secure=${secure}    alias=${alias}

common_dcap.Prepare BTS In DCAP
    [Arguments]    ${dcap_info}
    ...            ${bts_http_connection_info}
    ...            ${connection}
    [Documentation]
    ...    This kw is used to connect to DCAP server and assure the BTS integrated in the DCAP.
    ...    Supported BTS products: vdu, vcu, classical. (classcial BTS is not ready now)
    ...
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | dcap_info | yes | a dict, its keys are host, port, username, password, rd_version, secure, alias |
    ...    | bts_http_connection_info | yes |  |
    ...
    ...    Example
    ...   | Prepare BTS In DCAP |
    ...
    log to console    \nPreparing BTS In DCAP
    common_dcap.Connect To DCAP    alias=${connection}    &{dcap_info}
    common_dcap.Make Sure BTS Integrated In DCAP    ${bts_http_connection_info}

common_dcap.Start Trace In DCAP
    [Arguments]    ${bts_dic}    ${tag}=start_trace    ${force}=${True}
    ...            ${gnb_trace_profile}=${None}
    ...            ${vcu_trace_profile}=None
    ...            ${vdu_trace_profile}=None
    ...            ${enb_trace_profile}=None
    ...            ${bts_trace_profile}=None
    ...            ${custom_filter_file}=None
    ...            ${gnb_custom_profile_list}=None
    ...            ${enb_custom_profile_list}=None
    ...            ${vdu_custom_profile}=None
    ...            ${vcu_custom_profile}=None
    ...            ${gnb_custom_profile}=None
    ...            ${enb_custom_profile}=None
    ...            ${bts_custom_profile}=None
    ...            ${wait_for_activation}=${False}
    ...            ${timeout}=${400}
    ...            &{kwargs}
    [Documentation]    Used to start trace under DCAP.
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | bts_dic | yes | bts info as dict type |
    ...    | tag | no | the tag of this StartTraceBody. |
    ...    | force | no | signifying whether the trace should
    ...      force a shutdown of any previously running traces.
    ...      Defaults to true.
    ...      If the trace startup finds an ongoing trace and 'force' is
    ...      set to false, the startup fails due to ongoing traces error.
    ...      If the 'force' flag is set to true, the startup first shuts
    ...      downany ongoing traces and then continues with the startup |
    ...    | kwargs | no | options used as per requirement |
    ...
    ...    | Return Value | Description |
    ...    | trace_id | dcap trace id |
    ...
    ...    Example
    ...    | Start Trace In DCAP | ${bts_dic} | vcu_trace_profile=None
    ...        | vdu_trace_profile=dcap-lite-default
    ...
    ${trace_info}    dcaper.start_trace_in_dcap    ${bts_dic}    tag=${tag}    force=${force}
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
    ...    gnb_custom_profile=${gnb_custom_profile}
    ...    enb_custom_profile=${enb_custom_profile}
    ...    bts_custom_profile=${bts_custom_profile}
    ...    wait_for_activation=${wait_for_activation}
    ...    timeout=${timeout}
    ...    &{kwargs}
    [Return]    ${trace_info}[tracer_id]

common_dcap.Stop Trace In DCAP
    [Arguments]    ${btsip}    ${trace_id}=None
    [Documentation]    Used to stop trace under DCAP.
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | btsip | yes | bts ip address |
    ...    | trace_id | no | dcap trace id |
    ...    Example
    ...    | Stop Trace In DCAP |
    ...
    dcaper.stop_trace_in_dcap    ${btsip}    trace_id=${trace_id}

common_dcap.Make Sure BTS Integrated In DCAP
    [Arguments]    ${bts_dic}
    [Documentation]    Used to make sure the BTS is integrated in DCAP.
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | bts_dic | yes | bts info as dict type |
    ...    | Return Value | Description |
    ...    |  |  |
    ...    Example
    ...    | Make Sure BTS Integrated In DCAP | ${bts_dic}
    ...
    ${bts_web_ip}      Set Variable    ${bts_dic['host']}
    ${bts_username}    Set Variable    ${bts_dic['username']}
    ${bts_password}    Set Variable    ${bts_dic['password']}
    ${bts_port}        Set Variable    ${bts_dic['port']}
    ${all_bts_info}    dcaper.Get all bts info
    ${is_bts_exist}    set variable    ${false}
    FOR    ${info}    IN    @{all_bts_info}
        ${ip}     Set Variable    ${info['host']}
#        Run Keyword If    '${ip}'=='${bts_web_ip}'    Set Test Variable  ${is_bts_exist}  ${true}
        ${is_bts_exist} =    Set Variable If    '${ip}'=='${bts_web_ip}'    ${true}    ${is_bts_exist}
        Run Keyword If    ${is_bts_exist}    Exit For Loop
    END
    log    ${is_bts_exist}
    Run Keyword If    not ${is_bts_exist}    dcaper.Create bts to dcap    ${bts_web_ip}    btsport=${bts_port}
    ...    btsusername=${bts_username}    btspassword=${bts_password}    bts_alias=${bts_web_ip}

common_dcap.Make Sure Trace Status Ready
    [Arguments]    ${trace_id}
    [Documentation]    Used to make sure trace files are ready to download
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | trace_id | yes | to get trace info by trace id |
    ...    Example
    ...    | Make Sure Trace Status Ready | ${trace_id}
    ...
    ${trace_status}    dcaper.check_trace_status    ${trace_id}
    Should Be True    ${trace_status}

common_dcap.Make Sure Trace Stopped
    [Arguments]    ${btsip}    ${trace_id}=None
    [Documentation]    Used to make sure trace is stopped
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | trace_id | yes | to get trace info by trace id |
    ...    Example
    ...    | Make Sure Trace Stopped |
    ...
    ${trace_state}    dcaper.get_trace_state    ${btsip}    trace_id=${trace_id}
    ${is_stopped}=    Evaluate    "${trace_state}" in ["ready", "readyWithWarnings", "aborted", "failed"]
    Should Be True    ${is_stopped}

common_dcap.Download Trace File
    [Arguments]    ${btsip}    ${wait_time}=300s
    ...            ${timeout}=${3600}
    [Documentation]    Used to download trace files under DCAP.
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | btsip | yes | bts ip address |
    ...    | wait_time | no | times to check result from DCAP ready |
    ...    | timeout | no | timeout for trace file downloading |
    ...    Example
    ...    | Download Trace File | ${btsip}
    ...
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${log_dir_by_level}=    _CommonBTS.Get Log Directory For Log Module By Level
    ${dcap_local_file_path}    Join path    ${log_dir_by_level}    DCAP    ${timestamp}
    Create directory    ${dcap_local_file_path}
    ${last_trace_id}    dcaper.get_last_trace_id    ${btsip}
    Wait Until Keyword Succeeds    ${wait_time}    10s
    ...    common_dcap.Make Sure Trace Status Ready    ${last_trace_id}
    dcaper.download_trace_file
    ...    ${btsip}    target_dir=${dcap_local_file_path}
    ...    timeout=${timeout}
    [Return]    ${dcap_local_file_path}
