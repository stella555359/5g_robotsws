*** Settings ***
Documentation
...    Author: Liu, Renhui
...    Contact: renhui-david.liu@nokia-sbell.com

Resource          common/common_dcap.robot





*** Keywords ***
#---------------------DCAP--------------------------------------------------------------------------
common_worker.Start To Collect Log By DCAP
    [Arguments]    ${dcap_info}
    ...            ${log_type}
    ...            ${product_type}
    ...            ${cell_info}=${None}
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            &{trace_info}
    [Documentation]
    ...    This kw is for general use. It can capture various Log from different BTS products.
    ...    Supported various logs: tti, emil, troubleshooting scripts, etc.
    ...    Supported BTS products: vdu, vcu, classical. (classcial BTS is not ready now)
    ...
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | dcap_info | yes | a dict, its keys are host, username, password, port |
    ...    | product_type | yes | gnb, enb, vcu, vdu |
    ...    | bts_index | yes | BTS index |
    ...    | cudu_index | yes | the index of cu or du |
    ...    | trace_info | yes | decides which logs to caputre by specifying profiles |
    ...
    ...    | Return Value | Description |
    ...    | trace_id | dcap trace ID |
    ...
    ...    Example
    ...   | Start To Collect Log By DCAP |
    ...
    common_worker.Start DCAP Container
    ${bts_http_con_info}    Run Keyword If    '${product_type}' == 'vdu' or '${product_type}' == 'vcu'
    ...    product_config.Get BTS Http Connection Info
    ...    product_type=${product_type}    bts_index=${bts_index}    cudu_index=${cudu_index}
    ...    ELSE IF    '${product_type}' == 'gnb' or '${product_type}' == 'enb'
    ...    product_config.Get BTS OAM HTTP Connection Info    product_type=${product_type}    bts_index=${bts_index}
    Run Keyword If    ${cell_info} != ${None}    Set To Dictionary    ${bts_http_con_info}    &{cell_info}
    ${dcap_ip}=    Set Variable    ${dcap_info["host"]}
    ${connection}=    common_worker.get_dcap_connection_name    ${dcap_ip}
    common_dcap.Prepare BTS In DCAP    ${dcap_info}    ${bts_http_con_info}    ${connection}
    log to console    \nStarting trace by DCAP
    ${trace_id}=    Run Keyword If    '${log_type}'=='tssVdu'
    ...     common_dcap.Start Trace In DCAP    ${bts_http_con_info}    bts_Id=${bts_http_con_info.host}    &{trace_info}
    ...     ELSE
    ...     common_dcap.Start Trace In DCAP    ${bts_http_con_info}    &{trace_info}
    sleep    20s
    [Return]    ${trace_id}

common_worker.Stop and Download Log By DCAP
    [Arguments]    ${product_type}
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    [Documentation]
    ...    This kw is for general use. It can capture various Log from different BTS products.
    ...    Supported various logs: tti, emil, troubleshooting scripts, etc.
    ...    Supported BTS products: vdu, vcu, classical. (classcial BTS is not ready now)
    ...
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | dcap_info | yes | a dict, its keys are host, port, username, password, rd_version, secure and alias |
    ...    | product_type | yes | classical/vcu/vdu |
    ...    | bts_index | yes | BTS index |
    ...    | cudu_index | yes | the index of cu or du |
    ...    | trace_info | yes | other required parameters for the DCAP trace |
    ...
    ...    | Return Value | Description |
    ...    | trace_id | dcap trace ID |
    ...
    ...    Example
    ...   | Stop and Download Log By DCAP |
    ...
    [Timeout]    20 min
    ${bts_http_con_info}    Run Keyword If    '${product_type}' == 'vdu' or '${product_type}' == 'vcu'
    ...    product_config.Get BTS Http Connection Info
    ...    product_type=${product_type}    bts_index=${bts_index}    cudu_index=${cudu_index}
    ...    ELSE IF    '${product_type}' == 'gnb' or '${product_type}' == 'enb'
    ...    product_config.Get BTS OAM HTTP Connection Info    product_type=${product_type}    bts_index=${bts_index}

    ${bts_web_ip}=    Set Variable    ${bts_http_con_info["host"]}
    log to console    \nstopping trace
    common_dcap.Stop Trace In DCAP    ${bts_web_ip}
    log to console    \nDownloading logs
    ${dcap_local_file_path}    common_dcap.Download Trace File    ${bts_web_ip}
    @{files}    OperatingSystem.List Files In Directory    ${dcap_local_file_path}    *.zip
    ${dcap_archive_path}    set variable    ${dcap_local_file_path}/${files}[0]
    [Return]    ${dcap_archive_path}

common_worker.Wait For Trace and Download Log By DCAP
    [Arguments]    ${product_type}
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${wait_stop_time}=${None}
    ...            ${check_interval}=${None}
    [Documentation]
    ...    This kw is for general use. It can capture various Log from different BTS products.
    ...    If both wait_stop_time and check_interval are not None,
    ...    wait for the trace to finish until wait_stop_time is reached.
    ...    Supported various logs: tti, emil, troubleshooting scripts, etc.
    ...    Supported BTS products: vdu, vcu, classical. (classcial BTS is not ready now)
    ...
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | dcap_info | yes | a dict, its keys are host, port, username, password, rd_version, secure and alias |
    ...    | product_type | yes | classical/vcu/vdu |
    ...    | bts_index | yes | BTS index |
    ...    | cudu_index | yes | the index of cu or du |
    ...    | trace_info | yes | other required parameters for the DCAP trace |
    ...
    ...    | Return Value | Description |
    ...    | trace_id | dcap trace ID |
    ...
    ...    Example
    ...   | Wait For Trace and Download Log By DCAP |
    ...
    ${bts_http_con_info}    Run Keyword If    '${product_type}' == 'vdu' or '${product_type}' == 'vcu'
    ...    product_config.Get BTS Http Connection Info
    ...    product_type=${product_type}    bts_index=${bts_index}    cudu_index=${cudu_index}
    ...    ELSE IF    '${product_type}' == 'gnb' or '${product_type}' == 'enb'
    ...    product_config.Get BTS OAM HTTP Connection Info    product_type=${product_type}    bts_index=${bts_index}
    ${bts_web_ip}=    Set Variable    ${bts_http_con_info["host"]}

    Run keyword if    "${wait_stop_time}"!="NONE" and "${check_interval}"!="NONE"
    ...    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    ${wait_stop_time}    ${check_interval}
    ...    common_dcap.Make Sure Trace Stopped    ${bts_web_ip}

    ${dcap_archive_path}=    common_worker.Stop and Download Log By DCAP    ${product_type}
    ...    bts_index=${bts_index}
    ...    cudu_index=${cudu_index}
    [Return]    ${dcap_archive_path}

common_worker.Start To Collect Log By DCAP For MutiBTS
    [Arguments]    ${dcap_info}
    ...            ${log_type}
    ...            ${product_type}
    ...            ${cell_info}=${None}
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            &{trace_info}
    [Documentation]
    ...    This kw is for general use. It can capture various Log from different BTS products.
    ...    Supported various logs: tti, emil, troubleshooting scripts, etc.
    ...    Supported BTS products: vdu, vcu, classical. (classcial BTS is not ready now)
    ...
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | dcap_info | yes | a dict, its keys are host, username, password, port |
    ...    | product_type | yes | gnb, enb, vcu, vdu |
    ...    | bts_index | yes | BTS index |
    ...    | cudu_index | yes | the index of cu or du |
    ...    | trace_info | yes | decides which logs to caputre by specifying profiles |
    ...
    ...    | Return Value | Description |
    ...    | trace_id | dcap trace ID |
    ...
    ...    Example
    ...   | Start To Collect Log By DCAP |
    ...
    log    ${log_type}
    ${bts1_http_con_info}    Run Keyword If    '${product_type}' == 'vdu' or '${product_type}' == 'vcu'
    ...    product_config.Get BTS Http Connection Info
    ...    product_type=${product_type}    bts_index=${bts_index}    cudu_index=${cudu_index}
    ...    ELSE IF    '${product_type}' == 'gnb' or '${product_type}' == 'enb'
    ...    product_config.Get BTS OAM HTTP Connection Info    product_type=${product_type}    bts_index=${bts_index}
    ${bts2_http_con_info}=    Create Dictionary    host=10.0.1.3    port=443    username=Nemuadmin    password=nemuuser
    Run Keyword If    ${cell_info} != ${None}    Run Keywords
    ...    Set To Dictionary    ${bts1_http_con_info}    &{cell_info["bts1_cell"]}    AND
    ...    Set To Dictionary    ${bts2_http_con_info}    &{cell_info["bts2_cell"]}

    ${dcap_ip}=    Set Variable    ${dcap_info["host"]}
    ${connection}=    common_worker.get_dcap_connection_name    ${dcap_ip}
    common_dcap.Prepare BTS In DCAP    ${dcap_info}    ${bts1_http_con_info}    ${connection}
    common_dcap.Prepare BTS In DCAP    ${dcap_info}    ${bts2_http_con_info}    ${connection}
    log to console    \nStarting trace by DCAP
    ${bts_http_con_info}    Create List    ${bts1_http_con_info}    ${bts2_http_con_info}
    ${trace_id}=    common_dcap.Start Trace In DCAP    ${bts_http_con_info}    &{trace_info}
    sleep    20s
    [Return]    ${trace_id}

common_worker.Start To Collect Log By DCAP For Muti Gnb
    [Arguments]    ${dcap_info}
    ...            ${log_type}
    ...            ${product_type}
    ...            ${cell_info}=${None}
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            &{trace_info}
    log    ${log_type}
	log    ${product_type}
	log    ${bts_index}
	log    ${cudu_index}
    ${bts1_http_con_info}=  product_config.Get BTS OAM HTTP Connection Info
    ...    product_type=gnb
    ...    bts_index=${0}
    ...    port=443
    ${bts2_http_con_info}=  product_config.Get BTS OAM HTTP Connection Info
    ...    product_type=gnb
    ...    bts_index=${1}
    ...    port=443
    Run Keyword If    ${cell_info} != ${None}    Run Keywords
    ...    Set To Dictionary    ${bts1_http_con_info}    &{cell_info["bts1_cell"]}    AND
    ...    Set To Dictionary    ${bts2_http_con_info}    &{cell_info["bts2_cell"]}

    ${dcap_ip}=    Set Variable    ${dcap_info["host"]}
    ${connection}=    common_worker.get_dcap_connection_name    ${dcap_ip}
    common_dcap.Prepare BTS In DCAP    ${dcap_info}    ${bts1_http_con_info}    ${connection}
    common_dcap.Prepare BTS In DCAP    ${dcap_info}    ${bts2_http_con_info}    ${connection}
    log to console    \nStarting trace by DCAP
    ${bts_http_con_info}    Create List    ${bts1_http_con_info}    ${bts2_http_con_info}
    ${trace_id}=    common_dcap.Start Trace In DCAP    ${bts_http_con_info}    &{trace_info}
    sleep    20s
    [Return]    ${trace_id}
################################ Manage connection name #################################
common_worker.get_dcap_connection_name
    [Arguments]    ${dcap_ip}
    [Documentation]    Used to get an connection name. The name is automatically generated according to convention.
    ...    The advantage of this is to free the end users from managing aliases everywhere.
    ...    The convention for name is, dcap_${dcap_ip}
    ...
    ...    Author: Liu, Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | dcap_ip | yes | the dcap server ip |
    ...
    [Return]    dcap_${dcap_ip}

common_worker.Start DCAP Container
    [Documentation]
    ...	starts DCAP container on node-related test-vm
    ...
    [Arguments]   ${node_id}=${0}   ${node_type}=gnb   ${retry_counter}=6
    ${alias}=      common_worker.Connect to test pc    ${node_id}    ${node_type}
    ssh.execute   /usr/local/bin/DCAP_Basic_controller   connection=${alias}
    ssh.assert exit status   1   connection=${alias}
    ...   msg=DCAP startup failed, check DCAP deployment on Test-VM for ${node_type}${node_id}!
    ssh.execute  /usr/local/bin/DCAP_Basic_controller start  connection=${alias}

    FOR   ${loop_counter}   IN RANGE   ${retry_counter}
       ssh.execute   /usr/local/bin/DCAP_Basic_controller status   connection=${alias}
       ${rc}   ssh.get exit status   connection=${alias}
       EXIT FOR LOOP IF   ${rc}==${0}

       BuiltIn.Log   dcap not yet working, sleep 10s (loop ${loop_counter})   console=${P_admin_console}
       sleep   10s
    END

    Run Keyword If   ${rc}!=${0}   FAIL   startup DCAP container failed on Test-VM for ${node_type}${node_id}!

common_worker.Connect to test pc
    [Documentation]
    ...	connect UTE VM based on _init_.py
    ...
    [Arguments]     ${node_id}=${0}   ${node_type}=gnb
    ${alias}    Set variable   ${node_type}_${node_id}-test_pc
    ssh.Connect To   hostname=${tl.test_pcs[${node_id}].default_ssh_connection_details.addr}
    ...              username=${tl.test_pcs[${node_id}].default_ssh_connection_details.username}
    ...              password=uteUTE!
    ...              alias=${alias}
    ssh.Force Reconnect   ${alias}
    [Return]    ${alias}

common_worker.Get BTS Http Connection Info By Product Type
    [Arguments]    ${product_type}=gnb    ${bts_index}=${0}    ${cudu_index}=${0}
    ${bts_http_con_info}    Run Keyword If    '${product_type}' == 'vdu' or '${product_type}' == 'vcu'
    ...    product_config.Get BTS Http Connection Info
    ...    product_type=${product_type}    bts_index=${bts_index}    cudu_index=${cudu_index}
    ...    ELSE IF    '${product_type}' == 'gnb' or '${product_type}' == 'enb'
    ...    product_config.Get BTS OAM HTTP Connection Info    product_type=${product_type}    bts_index=${bts_index}
    ${bts_web_ip}=    Set Variable    ${bts_http_con_info["host"]}
    [Return]    ${bts_http_con_info}    ${bts_web_ip}

common_worker.Stop Log By DCAP
    [Arguments]    ${product_type}=gnb    ${bts_index}=${0}    ${cudu_index}=${0}
    [Timeout]    20 min
    ${bts_http_con_info}    ${bts_web_ip}=    common_worker.Get BTS Http Connection Info By Product Type
    ...    ${product_type}    ${bts_index}    ${cudu_index}
    log to console    \nstopping trace
    common_dcap.Stop Trace In DCAP    ${bts_web_ip}

common_worker.Download Log By DCAP
    [Arguments]    ${product_type}=gnb    ${bts_index}=${0}    ${cudu_index}=${0}
    [Timeout]    20 min
    ${bts_http_con_info}    ${bts_web_ip}=    common_worker.Get BTS Http Connection Info By Product Type
    ...    ${product_type}    ${bts_index}    ${cudu_index}
    log to console    \nDownloading logs
    ${dcap_local_file_path}    common_dcap.Download Trace File    ${bts_web_ip}
    @{files}    OperatingSystem.List Files In Directory    ${dcap_local_file_path}    *.zip
    ${dcap_archive_path}    set variable    ${dcap_local_file_path}/${files}[0]
    [Return]    ${dcap_archive_path}
