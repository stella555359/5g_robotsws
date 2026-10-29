*** Settings ***
Documentation
...    Author: Yang mengli
...    Email address: mengli.yang@nokia-sbell.com
...    Maintainer: Lou Sudi;    Liu Renhui
...    Email address: sudi.lou@nokia-sbell.com;    renhui-david.liu@nokia-sbell.com;
...    Common KWs related to collect logs from DCAP.
...    All the bugs/new keyword needs/improvement should be raised in Jira and assign to the Maintainer.
...    Jira link: https://jiradc.ext.net.nokia.com/projects/PZ1HAZTA/issues
...    Guideline: https://confluence.ext.net.nokia.com/display/SRANPRODHZHTA/09.+AIC+Common+Resource+Supporting+Mode+Improvement

Library           python/emil.py    WITH NAME    emil
Library           ../Cloud/python/basic.py    WITH NAME    basic
Library        String
Library        taf.transport.ssh                WITH NAME   ssh
Library    taf.sw.dcap.rd
Library    os

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

#---------------------DCAP--------------------------------------------------------------------------
Connect To DCAP
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
    dcap.connect_to_dcap    ${host}    ${port}
    ...                     username=${username}    password=${password}
    ...                     rd_version=${rd_version}
    ...                     secure=${secure}    alias=${alias}

Start Trace In DCAP
    [Arguments]    ${bts_dic}    ${tag}=start_trace    ${force}=${True}
    ...            ${gnb_trace_profile}=None
    ...            ${vcu_trace_profile}=None
    ...            ${vdu_trace_profile}=None
    ...            ${enb_trace_profile}=None
    ...            ${bts_trace_profile}=None
    ...            ${custom_filter_file}=None
    ...            ${gnb_custom_profile_list}=None
    ...            ${enb_custom_profile_list}=None
    ...            ${vdu_custom_profile}=None
    ...            ${vcu_custom_profile}=None
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
    ${trace_info}    dcap.start_trace_in_dcap    ${bts_dic}    tag=${tag}    force=${force}
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
    ...    &{kwargs}
    [Return]    ${trace_info}[tracer_id]

Stop Trace In DCAP
    [Arguments]    ${btsip}    ${trace_id}=None
    [Documentation]    Used to stop trace under DCAP.
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | btsip | yes | bts ip address |
    ...    | trace_id | no | dcap trace id |
    ...    Example
    ...    | Stop Trace In DCAP | gnb_index=${0} | vdu_index=${0} | timeout=${10}
    ...
    dcap.stop_trace_in_dcap    ${btsip}    trace_id=${trace_id}

Make Sure BTS Integrated In DCAP
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
    ${all_bts_info}    dcap.Get all bts info
    ${is_bts_exist}    set variable    ${false}
    FOR    ${info}    IN    @{all_bts_info}
        ${ip}     Set Variable    ${info['host']}
        Run Keyword If    '${ip}'=='${bts_web_ip}'    Set Test Variable  ${is_bts_exist}  ${true}
        Run Keyword If    ${is_bts_exist}    Exit For Loop
    END
    log    ${is_bts_exist}
    Run Keyword If    not ${is_bts_exist}    dcap.Create bts to dcap    ${bts_web_ip}    btsport=${bts_port}
    ...    btsusername=${bts_username}    btspassword=${bts_password}    bts_alias=${bts_web_ip}

Make Sure Trace Status Ready
    [Arguments]    ${trace_id}
    [Documentation]    Used to make sure trace files are ready to download
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | trace_id | yes | to get trace info by trace id |
    ...    Example
    ...    | Make Sure Trace Status Ready | ${trace_id}
    ...
    ${trace_status}    dcap.check_trace_status    ${trace_id}
    Should Be True    ${trace_status}

Download Trace File
    [Arguments]    ${btsip}    ${wait_time}=300s
    ...            ${timeout}=${600}
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
    ${dcap_local_file_path}    Join path    ${ TEST_LOG_DIRECTORY }    DCAP    ${timestamp}
    Create directory    ${dcap_local_file_path}
    Set Test Variable    ${dcap_local_file_path}
    ${last_trace_id}    dcap.get_last_trace_id    ${btsip}
    Wait Until Keyword Succeeds    ${wait_time}    10s
    ...    Make Sure Trace Status Ready    ${last_trace_id}
    dcap.download_trace_file
    ...    ${btsip}    target_dir=${dcap_local_file_path}
    ...    timeout=${timeout}
    [Return]    ${dcap_local_file_path}

Extract log from nested zip trace file
    [Arguments]    ${archive}    ${directory}    ${filters}
    [Documentation]  Used to extract log from trace file
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | archive | yes | zip file path |
    ...    | directory | yes | the directory to unzip file|
    ...    | filters | yes | a list, such as [{postfix=x, substring=x}, {postfix=xx, substring=xx}]|
    ${log_file_paths}    tti.extract_log_from_nested_zip_file    ${archive}    ${directory}    ${filters}
    [Return]    ${log_file_paths}

Extract log from trace file
    [Arguments]    ${tti_archive}    ${directory}    ${postfix}    ${substring}=${None}
    [Documentation]  Used to extract log from trace file
    ...    Author: Sudi Lou
    ...    Contact: sudi.lou@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | tti_archive | yes | zip file path, Name will be returned from Download Trace File keyword|
    ...    | directory | yes | the directory to unzip file|
    ...    | postfix | yes | the postfix of log name|
    ...    | substring | yes | require the log filename contains this substring|
    ${log_file_paths}    tti.extract_log_from_zip_file    ${tti_archive}    ${directory}    ${postfix}
    ...    substring=${substring}
    [Return]    ${log_file_paths}

Update DCAP Controller White List
    [Arguments]    ${hostname}    ${username}    ${password}    ${namespace}
    ...            ${dcap_ip}    ${operation_type}
    [Documentation]  Used to add dcap controller white list in CNF.
    ...    Author: Sudi Lou
    ...    Contact: sudi.lou@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | hostname | yes | ip address of cnf |
    ...    | username | yes | username of cnf |
    ...    | password | yes | password of cnf |
    ...    | namespace | yes | namespace of cnf |
    ...    | dcap_ip | yes | dcap server ip address |
    ...    | operation_type | yes | must be add or delete |
    ${pod_name}    set variable  po-${namespace}-oamext-0
    ${container_name}    set variable  ctr-${namespace}-providercontroller

    ${conn}=    basic.master_connect    hostname=${hostname}
    ...                                 username=${username}
    ...                                 password=${password}
    Run Keyword If     '${operation_type}'=='add'
        ...             k8s.add_dcap_controller_white_list    ${namespace}    ${pod_name}    ${container_name}
        ...                                                   ${dcap_ip}    ${conn}
    ...    ELSE IF     '${operation_type}'=='delete'
        ...             k8s.delete_dcap_controller_white_list    ${namespace}    ${pod_name}    ${container_name}
        ...                                                      ${dcap_ip}    ${conn}
    ...    ELSE   fail    not support this operation_type
    [Teardown]    run keyword and ignore error    basic.master_close    alias=${conn}

Convert Emil Log to CSV
    [Arguments]    ${emil_log_file}   ${profile_path}=5G    ${timeout}=60
    ...    ${emil_host}=${emil_host}
    ...    ${emil_user}=${emil_user}
    ...    ${emil_password}=${emil_password}
    ...    ${emil_log_win_dir}=C:\\\\emil_logs
    ...    ${emil_tool_win_path}=C:\\\\Program Files\\\\Emil
    ...    ${emil_log_dir}=C:\\\\emil_logs
    ...    ${emil_tool_path}=C:\\\\Program Files\\\\Emil
    [Documentation]  Covert Emil Log to csv file
    ...    Author: Sudi Lou
    ...    Contact: sudi.lou@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | emil_log_file | yes | emil log file path |
    ...    | profile_path | yes | profile path name, can be 5G, 5G Cell Trace, 5G L2, LTE |
    ${local_file_path}   ${emil_log_name}   Split Path    ${emil_log_file}
    ${bat_file_name}  ${csv_file_name}    emil.creat_bat_file    local_file_path=${local_file_path}
    ...                                                          emil_log_name=${emil_log_name}
    ...                                                          emil_log_win_dir=${emil_log_win_dir}
    ...                                                          emil_tool_win_path=${emil_tool_win_path}
    ...                                                          profile_path=${profile_path}
    ${conn}=    basic.master_connect    hostname=${emil_host}
    ...                                 username=${emil_user}
    ...                                 password=${emil_password}
    emil.upload_log_and_bat_files    local_file_path=${local_file_path}    emil_log_name=${emil_log_name}
    ...                              bat_file_name=${bat_file_name}    emil_log_dir=${emil_log_dir}
    ...                              connection=${conn}
    emil.convert_log_to_csv    emil_tool_path=${emil_tool_path}    emil_log_win_dir=${emil_log_win_dir}
    ...                        bat_file_name=${bat_file_name}    connection=${conn}    timeout=${timeout}
    emil.download_output_file    emil_log_dir=${emil_log_dir}    local_file_path=${local_file_path}
    ...                          csv_file_name=${csv_file_name}    connection=${conn}
    [Return]   ${local_file_path}/${csv_file_name}
    [Teardown]    Run keywords    emil.remove_log_files    emil_log_dir=${emil_log_dir}    emil_log_name=${emil_log_name}
    ...                      bat_file_name=${bat_file_name}    csv_file_name=${csv_file_name}
    ...                      connection=${conn}    timeout=${timeout}
    ...            AND      run keyword and ignore error    basic.master_close    alias=${conn}

Convert Emil Log to Ascii
    [Arguments]    ${emil_log_file}   ${profile_path}=5G    ${timeout}=60
    ...    ${emil_host}=${emil_host}
    ...    ${emil_user}=${emil_user}
    ...    ${emil_password}=${emil_password}
    ...    ${emil_log_win_dir}=C:\\\\emil_logs
    ...    ${emil_tool_win_path}=C:\\\\Program Files\\\\Emil
    ...    ${emil_log_dir}=C:\\\\emil_logs
    ...    ${emil_tool_path}=C:\\\\Program Files\\\\Emil
    [Documentation]  Covert Emil Log to Ascii file
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | emil_log_file | yes | emil log file path |
    ...    | profile_path | yes | profile path name, can be 5G, 5G Cell Trace, 5G L2, LTE |
    ${local_file_path}   ${emil_log_name}   Split Path    ${emil_log_file}
    ${bat_file_name}  ${target_file_name}    emil.creat_bat_file_for_ascii    local_file_path=${local_file_path}
    ...                                                          emil_log_name=${emil_log_name}
    ...                                                          emil_log_win_dir=${emil_log_win_dir}
    ...                                                          emil_tool_win_path=${emil_tool_win_path}
    ...                                                          profile_path=${profile_path}
    ${conn}=    basic.master_connect    hostname=${emil_host}
    ...                                 username=${emil_user}
    ...                                 password=${emil_password}
    emil.upload_log_and_bat_files    local_file_path=${local_file_path}    emil_log_name=${emil_log_name}
    ...                              bat_file_name=${bat_file_name}    emil_log_dir=${emil_log_dir}
    ...                              connection=${conn}
    emil.convert_log_to_csv    emil_tool_path=${emil_tool_path}    emil_log_win_dir=${emil_log_win_dir}
    ...                        bat_file_name=${bat_file_name}    connection=${conn}    timeout=${timeout}
    emil.download_output_file    emil_log_dir=${emil_log_dir}    local_file_path=${local_file_path}
    ...                          csv_file_name=${target_file_name}    connection=${conn}
    [Return]   ${local_file_path}/${target_file_name}
    [Teardown]    Run keywords    emil.remove_log_files    emil_log_dir=${emil_log_dir}    emil_log_name=${emil_log_name}
    ...                      bat_file_name=${bat_file_name}    csv_file_name=${target_file_name}
    ...                      connection=${conn}    timeout=${timeout}
    ...            AND      run keyword and ignore error    basic.master_close    alias=${conn}

Start DCAP Container
    [Documentation]
    ...	starts DCAP container on node-related test-vm
    ...
    [Arguments]   ${node_id}=${1}   ${node_type}=enb   ${retry_counter}=6
    ${alias}=      Connect to test pc    ${node_id}    ${node_type}
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

Connect to test pc
    [Documentation]
    ...	connect UTE VM based on _init_.py
    ...
    [Arguments]     ${node_id}=${1}   ${node_type}=enb
    ${alias}    Set variable   ${node_type}_${node_id}-test_pc
    ssh.Connect To   hostname=${tl.test_pcs[${node_id}].default_ssh_connection_details.addr}
    ...              username=${tl.test_pcs[${node_id}].default_ssh_connection_details.username}
    ...              password=uteUTE!
    ...              alias=${alias}
    ssh.Force Reconnect   ${alias}
    [Return]    ${alias}


Stop DCAP Container
    [Documentation]
    ...	stops DCAP container on node-related test-vm
    ...
    [Arguments]   ${node_id}=${0}   ${node_type}=gnb
    ${dcap_alias}=   Connect to test pc    ${node_id}   ${node_type}

    ssh.execute   /usr/local/bin/DCAP_Basic_controller   connection=${dcap_alias}
    ${rc}   ssh.get exit status   connection=${dcap_alias}
    Run Keyword If   '${rc}'=='${1}'   ssh.execute   /usr/local/bin/DCAP_Basic_controller stop   connection=${dcap_alias}


Start DCAP Container For All Nodes
    [Documentation]
    ...	starts DCAP container on node-related test-vm for all nodes defined in TL config
    ...
    [Arguments]   ${node_type}=gnb   ${retry_counter}=6
    ${node_num}   Get Length   ${tl.${node_type}s}
    FOR   ${node_id}   IN RANGE   ${node_num}
       Start DCAP Container   node_id=${node_id}   node_type=${node_type}   retry_counter=${retry_counter}
    END


Stop DCAP Container For All Nodes
    [Documentation]
    ...	stops DCAP container on node-related test-vm for all nodes defined in TL config
    ...
    [Arguments]    ${node_type}=gnb
    ${node_num}   Get Length    ${tl.${node_type}s}
    FOR    ${node_id}    IN RANGE    ${node_num}
           Stop DCAP Container  ${node_id}  ${node_type}
    END

Get Emil Data In CSV Via Webemil
    [Arguments]    ${file_name}    ${what}=source    ${connection}=None    &{kwargs}
    [Documentation]  This method returns csv files with Emil data rows from the decoded logs via webemil tool
    ...    Author: Sudi Lou
    ...    Contact: sudi.lou@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | file_name | yes | Emil log file name,  can be str or list[str] |
    ...    | what | yes | Type of data to be returned, can be source or calls, default value is source |
    ...    | connection | yes | DcapConnection |
    ...    | kwargs | no | supported filter param now, specifies condition that a data row must fulfill to be included in the results,
    ...    Example: filter='Message name=NsetapX_IsAlive' |
    ${output_file_name_list}    emil.get_emil_data_in_csv_via_webemil    file_name=${file_name}
    ...                                                                  what=${what}
    ...                                                                  connection=${connection}
    ...                                                                  &{kwargs}

    [Return]   ${output_file_name_list}
Download Wireshark Plugin Nsetapx
    [Arguments]    ${web_path}=https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/NSETAP_X
    ...            ${nsetapx_verion}=nsetapx-1.12.6
    ...            ${nsetapx_file}=nsetapx-4.0-0.6.1-1.12.6+buster.so
    ...            ${plugin_folder}=/usr/lib/x86_64-linux-gnu/wireshark/plugins
    [Documentation]    This kw is used to Download Wireshark Plugin Nsetapx
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | web_path | yes | Nsetapx package path |
    ...    | nsetapx_verion | yes | this parameter indicate Nsetapx version |
    ...    | nsetapx_file | yes | set nsetapx file name you want to use |
    ...    | plugin_folder | yes |set plugin storage path in your VM |
    Log to console    Get nsetapx plugin..
    ${ver}   Run   ls ${plugin_folder}/
    ${plugin_path}    set Variable    ${plugin_folder}/${ver}/epan
    ${check}    Run    if test -e ${plugin_path}/${nsetapx_file} ; then echo "true" ; else echo "false" ;fi
	Run Keyword If    "${check}"=="false"    Download Nsetapx Plugin File    plugin_path=${plugin_path}
	...                                                  web_path=${web_path}
	...                                                  nsetapx_verion=${nsetapx_verion}
	...                                                  nsetapx_file=${nsetapx_file}

Download Nsetapx Plugin File
    [Arguments]    ${plugin_path}
    ...            ${web_path}=https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/NSETAP_X
    ...            ${nsetapx_verion}=nsetapx-1.12.6
    ...            ${nsetapx_file}=nsetapx-4.0-0.6.1-1.12.6+buster.so
    [Documentation]    This kw is used to Download Nsetapx Plugin File
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | web_path | yes | Nsetapx package path |
    ...    | nsetapx_verion | yes | this parameter indicate Nsetapx version |
    ...    | nsetapx_file | yes | set nsetapx file name you want to use |
    ...    | plugin_folder | yes |set plugin storage path in your VM |
    ${wireshark_version}    Run     wireshark --version
    ${output}    Run    sudo wget ${web_path}/${nsetapx_verion}/${nsetapx_file}
    Run    sudo cp ./${nsetapx_file} ${plugin_path}
    ${check}    Run    if test -e ${plugin_path}/${nsetapx_file} ; then echo "true" ; else echo "false" ;fi
    Should be true    "${check}"=="true"    Plugin file not exist!
    Run    sudo chmod 777 -R ${plugin_path}/${nsetapx_file}

Get Emil Decoded Data In Json
    [Arguments]    ${file_path}    ${what}=source    ${connection}=None    &{kwargs}
    [Documentation]  This method returns json file with Emil data rows from the decoded logs
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | file_path | yes | Emil log file path,example:/home/ute/4813_10.97.83.130_20240914T072347_control-plane.5gm |
    ...    | what | yes | Type of data to be returned, can be source or calls, default value is source |
    ...    | connection | yes | DcapConnection |
    ...    | kwargs | no | supported filter param now, specifies condition that a data row must fulfill to be included in the results,
    ...    Example: filter=['ZMQ/SCTP name=CpUePmiTicket'] |
    Log To Console    ${what}
    ${uploaded_file_info}     upload_encoded_file    file_name=${file_path}
    ...       connection=${connection}
    ${session_id}    set variable    ${uploaded_file_info['session_id']}
    ${data_source_id}   set variable    ${uploaded_file_info['source_ids']}[${0}]
    ${res}    get_decoded_file_contents_in_json    session_id=${session_id}    data_source_id=${data_source_id}
    ...      what=source      connection=${connection}    &{kwargs}
    ${file_dir}    ${file_name}    evaluate     os.path.split("${file_path}")    modules=os
    ${timestamp}    DateTime.Get Current Date
    log to console     ${timestamp}
    emil.save_content_to_json_file    content=${res}     file_path=${file_dir}/emil_${timestamp}.json
    delete_session_data     session_id=${session_id}    connection=${connection}
    [Return]   ${file_dir}/emil_${timestamp}.json
