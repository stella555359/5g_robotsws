*** Settings ***
Library        String
Library        taf.transport.ssh                WITH NAME   ssh
Library        ../resources/lib/dcap.py     WITH NAME    dcap
Documentation
    ...     Keywords for dcap handling, default is set to emil traces
    ...     from HZ
    ...     trace type is generally set by custom profile variable;
    ...     possible options (only gNB (5G) options) are listed here:
    ...    | cp_5g, immediateSnapshot_5g, pmFiles5g, condor5gSyslog, SCF5g, L2Ps_Component, L2Lo_Component,
    ...    | L2HiRlc_Component, L2HiPdcp_Component, L2Ps_Sherpa, L2Lo_Sherpa, L2HiRlc_Sherpa,             |
    ...    | L2HiPdcp_Sherpa, bip_interface_mirroring, L1stream
    ...
    ...    these values are defined in
    ...
    ...    https://taf-sw-dcap-rd.docs.taf.ute.nsn-rdnet.net/en/latest/interfaces/interface.html#
    ...    taf.sw.dcap.rd.interface.rd.start_trace
    ...
    ...    and mapped to a tracer_id and trace interface. This mapping and detailed setting for each profile
    ...    can be found in dcap code:
    ...
    ...    robotws/.venv/lib/python3.6/site-packages/taf/sw/dcap/rd/cm/cm_base.py
    ...
    ...    several traces can be started and stopped together by creating a list of custom profiles, but at the
    ...    moment it's not
    ...    possible to start single traces on after the other.
    ...
    ...    The following table shows the tested custom profiles and the supported sequence for each.
    ...    If you mix multiple custom profiles be sure they are compatible with each other.
    ...    Mixing profiles that require only start/stop with profiles that require start/stop/collect works
    ...    but requires also
    ...    start/stop/collect sequence.
    ...    Consider putting the Collect in the teardown of the keyword, so that if the stop fails you are still
    ...    able to get some logs.
    ...    Feel free to modify the table if your experience does not match the information provided there or if
    ...    there is missing data.
    ...
    ...    | Custom Profile          | Start/Stop/Collect  | Start/Collect |
    ...    | cp_5g                   | X                   |               |
    ...    | immediateSnapshot_5g    | X                   |               |
    ...    | pmFiles5g               |                     | X             |
    ...    | condor5gSyslog          |                     |               |
    ...    | SCF5g                   |                     | X             |
    ...    | L2Ps_Component          | (need cells on air) |               |
    ...    | L2Lo_Component          | (need cells on air) |               |
    ...    | L2HiRlc_Component       | (need cells on air) |               |
    ...    | L2HiPdcp_Component      | (need cells on air) |               |
    ...    | L2Ps_Sherpa             | (need cells on air) |               |
    ...    | L2Lo_Sherpa             | (need cells on air) |               |
    ...    | L2HiRlc_Sherpa          | (need cells on air) |               |
    ...    | L2HiPdcp_Sherpa         | (need cells on air) |               |
    ...    | bip_interface_mirroring | (need cells on air) |               |
    ...    | L1stream                |                     |               |
    ...


*** Variables ***
${P_admin_console}              ${False}    # debug output to console


*** Keywords ***
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
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${node_id}: <description>
    ...        ${node_type}: <description>
    ...
    ...    Returns:
    ...        ${alias}: <description>
    [Arguments]     ${node_id}=${1}   ${node_type}=enb
    ${alias}    Set variable   ${node_type}_${node_id}-test_pc
    Log  ${tl.test_pcs[${node_id}].default_ssh_connection_details.username}
    #Log  ${${tl.${node_type}s[${node_id}]}}
    Log  uteUTE!
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
    Run Keyword If   '${rc}'=='${1}'   ssh.execute   /usr/local/bin/DCAP_Basic_controller stop
    ...   connection=${dcap_alias}

Start DCAP Container For All Nodes
    [Documentation]
    ...	starts DCAP container on node-related test-vm for all nodes defined in TL config
    ...
    [Arguments]   ${node_type}=gnb   ${retry_counter}=6
    ${node_num}   Get Length    ${tl.${node_type}s}
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
    ...            ${wait_for_activation}=${TRUE}
    ...            ${timeout}=${400}
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
    ...    | Return Value | Description |
    ...    | trace_id | dcap trace id |
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
    [Return]    ${trace_info}[tracer_id]

Stop Trace In DCAP
    [Arguments]    ${btsip}
    [Documentation]    Used to stop trace under DCAP.
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | btsip | yes | bts ip address |
    ...    Example
    ...    | Stop Trace In DCAP | gnb_index=${0} | vdu_index=${0} | timeout=${10}
    ...
    dcap.stop_trace_in_dcap    ${btsip}

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
    [Arguments]    ${trace_id}    ${connection}=dcap
    [Documentation]    Used to make sure trace files are ready to download
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | trace_id | yes | to get trace info by trace id |
    ...    Example
    ...    | Make Sure Trace Status Ready | ${trace_id}
    ...
    ${trace_status}    dcap.check_trace_status    ${trace_id}    ${connection}
    Should Be True    ${trace_status}

Download Trace File
    [Arguments]    ${btsip}    ${wait_time}=300s
    ...            ${timeout}=${600}    ${connection}=dcap
    [Documentation]    Used to download trace files under DCAP.
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | btsip | yes | bts ip address |
    ...    | wait_time | no | times to check result from DCAP ready |
    ...    | timeout | no | timeout for trace file downloading |
    ...    Example
    ...    | Download Trace File With Poll | ${btsip}
    ...
    Log    ${wait_time}
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${dcap_local_file_path}    Join path    ${Test Results Dir}    DCAP    ${timestamp}    ${snapshot}
    Create directory    ${dcap_local_file_path}
    Set Test Variable    ${dcap_local_file_path}
   # ${last_trace_id}    dcap.get_last_trace_id    ${btsip}
    dcap.download_trace_file
    ...    ${btsip}    target_dir=${dcap_local_file_path}
    ...    timeout=${timeout}     connection=${connection}
    [Return]    ${dcap_local_file_path}

Extract log from trace file
    [Arguments]    ${tti_archive}    ${directory}    ${postfix}
    [Documentation]  Covert Emil Log to csv file
    ...    Author: Sudi Lou
    ...    Contact: sudi.lou@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | tti_archive | yes | zip file path, Name will be returned from Download Trace File keyword|
    ...    | directory | yes | the directory to unzip file|
    ...    | postfix | yes | the postfix of log name|
    ${log_file_paths}    tti.extract_log_from_zip_file    ${tti_archive}    ${directory}    ${postfix}
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

Covert Emil Log to CSV
    [Arguments]    ${emil_log_file}   ${profile_path}=5G
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
    ...                        bat_file_name=${bat_file_name}    connection=${conn}
    emil.download_output_file    emil_log_dir=${emil_log_dir}    local_file_path=${local_file_path}
    ...                          csv_file_name=${csv_file_name}    connection=${conn}
    emil.remove_log_files    emil_log_dir=${emil_log_dir}    emil_log_name=${emil_log_name}
    ...                      bat_file_name=${bat_file_name}    csv_file_name=${csv_file_name}
    ...                      connection=${conn}
    [Return]   ${local_file_path}/${csv_file_name}
    [Teardown]    run keyword and ignore error    basic.master_close    alias=${conn}
