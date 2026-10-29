*** Settings ***

Documentation   Keywords for connection handling

Library   String
Library   OperatingSystem

Library   taf.sbts.oam.coam.admin          WITH NAME   admin
Library   taf.gnb.oam.coam.cu              WITH NAME   coam_cu
Library   taf.transport.ssh                WITH NAME   ssh

Library   ../python/connect.py             WITH NAME   connect_py

Resource   TARF-Keywords.robot

*** Variables ***
${P_admin_console}              ${False}   # debug output to console for setup oam http connections

*** Keywords ***
Connect to OAM
    [Documentation]
    ...     Setup ssh connection to OAM and returns connection handle/alias
    ...
    ...     An alias can used as argument, but better use the returned alias.
    ...
    ...     | gnb_id | Id/Number of gNB |
    ...     | alias  | alias used for ssh connection |
    ...     | force  | session reconnection if needed (either True or False) |
    ...
    ...     *Example*
    ...
    ...     | ${oam_alias}  connect.Connect to OAM
    ...     | ssh.execute  command=ls  connection=${oam_alias}
    ...
    ...     *Returns*   alias for ssh connection to OAM
    ...
    [Arguments]   ${gnb_id}=${0}   ${alias}=ssh-gnb-${gnb_id}-oam   ${force}=${False}

    ${test_pc_connection_count}=   Get Length    ${tl.test_pc.connections}
    ${proxy}   Run keyword If   ${test_pc_connection_count}==0   Connect to test pc proxy for node   node_id=${gnb_id}
    ...    ELSE   Set Variable   ${None}
    ssh.Connect To   hostname=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.addr}
    ...              username=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.username}
    ...              password=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.password}
    ...              alias=${alias}
    ...              proxy=${proxy}
    Run Keyword If   ${force}   ssh.Force Reconnect    ${alias}
    [Return]   ${alias}


Connect to gNB VM
    [Documentation]
    ...     setup ssh connection to VM
    ...     ssh connection is done via OAM as proxy
    ...     VM FQDN     ${vm_name}-0.local
    ...
    ...     | vm_name | Name of virual machine (cpcl|cpif|cpnb|cpue|upue|cpnrt) |
    ...     | gnb_id  | Id/Number of gNB |
    ...     | alias   | alias used for ssh connection |
    ...     | force  | session reconnection if needed (either True or False) |
    ...
    ...     *Example*
    ...
    ...     | ${cpue_alias}  connect.Connect to gNB VM  vm_name=cpue
    ...     | ssh.execute  command=uptime  connection=${cpue_alias}
    ...
    ...     *Returns*   alias for ssh connection to OAM
    ...
    [Arguments]   ${vm_name}   ${gnb_id}=${0}   ${alias}=ssh-gnb-${gnb_id}-${vm_name}   ${force}=${False}
    ${oam_alias}    connect.Connect to OAM   gnb_id=${gnb_id}
    ssh.Connect To   hostname=${vm_name}-0.local
    ...              username=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.username}   # same as oam
    ...              password=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.password}   # same as oam
    ...              proxy=${oam_alias}
    ...              alias=${alias}
    Run Keyword If   ${force}   ssh.Force Reconnect    ${alias}
    [Return]   ${alias}


Connect to Core
    [Documentation]
    ...     setup ssh connection core and returns connection handle/alias
    ...     KW sould be called without arguments
    ...
    ...     | alias | alias used for ssh connection |
    ...     | force | session reconnection if needed (either True or False) |
    ...
    ...     *Returns*   alias for ssh connection to OAM
    ...
    [Arguments]    ${alias}=ssh-core       ${force}=${False}
    ssh.Connect To   hostname=${tl.core.default_ssh_connection_details.addr}
    ...              username=${tl.core.default_ssh_connection_details.username}
    ...              password=${tl.core.default_ssh_connection_details.password}
    ...              alias=${alias}
    Run Keyword If   ${force}   ssh.Force Reconnect    ${alias}
    [Return]    ${alias}


Connect to Node Common Unit
    [Documentation]
    ...     setup ssh connection to Airscale (ASXX) and returns connection handle/alias
    ...
    ...     | node_id   | Id of gnb [0.. ] |
    ...     | node_type | either gnb or enb (gnb|enb) |
    ...     | du_id     | Id of DU [0.. ] |
    ...     | comu_id   | Id of Common Unit [0..1] |
    ...     | alias     | connection alias, should not be used !! |
    ...     | force     | session reconnection if needed (either True or False) |
    ...
    ...     *Example*
    ...
    ...     | ${asxx_alias}   connect.Connect to Node Common Unit    node_id=0  du_id=0  comu_id=0
    ...     | ssh.execute     command=uptime  connection=${asxx_alias}
    ...
    ...     *Returns*     alias for ssh connection to Common Unit
    ...
    [Arguments]   ${node_id}=${0}   ${node_type}=gnb   ${du_id}=${0}   ${comu_id}=${0}
    ...           ${alias}=ssh-${node_type}-${node_id}-${du_id}-${comu_id}   ${force}=${False}
    ${proxy}    Get test pc proxy for ssh connection    node_type=${node_type}    node_id=${node_id}

    ${parent}   Set Variable If   '${node_type}'=='gnb'   dus[${du_id}].airscale
    ...                           '${node_type}'=='enb'   system_module

    ssh.Connect To   hostname=${tl.${node_type}s[${node_id}].${parent}.common_units[${comu_id}].lmp_connection.addr}
    ...              username=${tl.${node_type}s[${node_id}].${parent}.common_units[${comu_id}].lmp_connection.username}
    ...              password=${tl.${node_type}s[${node_id}].${parent}.common_units[${comu_id}].lmp_connection.password}
    ...              alias=${alias}
    ...              proxy=${proxy}
    Run Keyword If   ${force}   ssh.Force Reconnect    ${alias}
    [Return]    ${alias}


Connect to gNB Capacity Unit
    [Documentation]
    ...     setup ssh connection to Loner (ABXX) and returns connection handle/alias
    ...
    ...     | gnb_id  | Id of gnb [0.. ] |
    ...     | du_id   | Id of DU [0.. ] |
    ...     | comu_id | Id of Common Unit [0..1] |
    ...     | capu_id | Id of Capacity Unit [0..5] |
    ...     | slave   | Name of Slave of Capacity unit (a|b|loner) |
    ...     | alias   | connection alias, should not be used !! |
    ...     | force   | session reconnection if needed (either True or False) |
    ...
    ...     *Example*
    ...
    ...     | # setup connection to loner
    ...     | ${loner_alias}   connect.Connect to gNB Capacity Unit    gnb_id=0  du_id=0  comu_id=0  capu_id=0  slave=loner
    ...     | ssh.execute     command=uptime  connection=${loner_alias}
    ...
    ...     *Returns*     alias for ssh connection to Capacity Unit
    ...
    [Arguments]    ${gnb_id}=${0}   ${du_id}=${0}   ${comu_id}=${0}   ${capu_id}=${0}   ${slave}=a
    ...            ${alias}=ssh-gnb-${gnb_id}-${du_id}-${comu_id}-${capu_id}-${slave}   ${force}=${False}
    # setup connection to Common Unit as ssh hop
    ${comu_alias}   Connect to Node Common Unit   node_id=${gnb_id}   du_id=${du_id}   comu_id=${comu_id}
    ${ip}   testline-Keywords.Get Capacity Slave IP   gnb_id=${gnb_id}   du_id=${du_id}   comu_id=${comu_id}   capu_id=${capu_id}
    ...     slave=${slave}

    ssh.Connect To   hostname=${ip}
    ...              username=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.username}
    ...              password=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.password}
    ...              proxy=${comu_alias}
    ...              alias=${alias}
    Run Keyword If   ${force}   ssh.Force Reconnect    ${alias}
    [Return]    ${alias}


Connect to UE PC
    [Documentation]
    ...     Setup ssh connection to UE control PC
    ...
    ...     | ue_id | ue id |
    ...     | alias | alias used for ssh connection |
    ...     | force | session reconnection if needed (either True or False) |
    ...
    ...     *Returns*  alias for ssh connection to Testpc
    ...
    [Arguments]   ${ue_id}=${0}   ${alias}=ssh-ue-pc-${ue_id}   ${force}=${False}
    ${hostname}   Get Variable Value   ${tl.ues[${ue_id}].ssh_connection_details.addr}   ${tl.ues[${ue_id}].ue_pc_address}
    ${username}   Get Variable Value   ${tl.ues[${ue_id}].ssh_connection_details.username}   deul5g
    ${password}   Get Variable Value   ${tl.ues[${ue_id}].ssh_connection_details.password}   Nuc2Ue4PzLab!
    ssh.Connect To   hostname=${hostname}
    ...              username=${username}
    ...              password=${password}
    ...              alias=${alias}
    Run Keyword If   ${force}   ssh.Force Reconnect    ${alias}
    [Return]    ${alias}



Connect to UE application server
    [Documentation]
    ...     Setup ssh connection to UE appserv PC and
    ...     returns connection handle/alias.
    ...
    ...     *Note:* KW sould be called without arguments
    ...
    ...     | ue_id | ue id |
    ...     | alias | alias used for ssh connection, should not be used !! |
    ...     | force | session reconnection if needed (either True or False) |
    ...
    ...     *Example*
    ...
    ...     | ${alias}  connect.Connect to UE appserv
    ...     | ssh.execute  command=ls  connection=${alias}
    ...
    ...     *Returns* alias for ssh connection to UE appserv
    ...
    [Arguments]    ${ue_id}=${0}    ${alias}=ssh-ue-${ue_id}-appserv   ${force}=${False}
    ${appserv_addr}   Get Variable Value   ${tl.ues[${ue_id}].data_transfer[0].app_server.address}\
    ...   ${tl.ues[${ue_id}].iperf_details.ssh_connection_details.addr}
    ${appserv_username}   Get Variable Value   ${tl.ues[${ue_id}].data_transfer[0].app_server.username}\
    ...   ${tl.ues[${ue_id}].iperf_details.ssh_connection_details.username}
    ${appserv_password}   Get Variable Value   ${tl.ues[${ue_id}].data_transfer[0].app_server.password}\
    ...   ${tl.ues[${ue_id}].iperf_details.ssh_connection_details.password}

    ssh.Connect To   hostname=${appserv_addr}
    ...              username=${appserv_username}
    ...              password=${appserv_password}
    ...              alias=${alias}
    Run Keyword If   ${force}   ssh.Force Reconnect    ${alias}
    [Return]   ${alias}


Connect to core application server
    [Documentation]
    ...     Setup ssh connection to core appserv PC and
    ...     returns connection handle/alias.
    ...
    ...     *Note:* KW sould be called without arguments
    ...
    ...     | alias | alias used for ssh connection, should not be used !! |
    ...     | force | session reconnection if needed (either True or False) |
    ...
    ...     *Example*
    ...
    ...     | ${alias}  connect.Connect to core appserv
    ...     | ssh.execute  command=ls  connection=${alias}
    ...
    ...     *Returns* alias for ssh connection to core appserv
    ...
    [Arguments]    ${alias}=ssh-core-appserv   ${force}=${False}
    ssh.Connect To   hostname=${tl.appserver.iperf_details.ssh_connection_details.addr}
    ...              username=${tl.appserver.iperf_details.ssh_connection_details.username}
    ...              password=${tl.appserver.iperf_details.ssh_connection_details.password}
    ...              alias=${alias}
    Run Keyword If   ${force}   ssh.Force Reconnect    ${alias}
    [Return]   ${alias}


Connect to Airphone Common Unit
    [Documentation]
    ...     setup ssh connection to Airphone Airscale (ASXX) and returns connection handle/alias
    ...
    ...     | ue_id      | Id of UE [0.. ] |
    ...     | ue_comu_id | Id of AP Common Unit [0..1] |
    ...     | alias      | connection alias, should not be used !! |
    ...     | force      | session reconnection if needed (either True or False) |
    ...
    ...     *Example*
    ...
    ...     | ${ap_alias}   connect.Connect to Airphone Common Unit    ue_id=0  ue_comu_id=0
    ...     | ssh.execute     command=uptime  connection=${ap_alias}
    ...
    ...     *Returns*     alias for ssh connection to Common Unit
    ...
    [Arguments]    ${ue_id}=${0}    ${ue_comu_id}=${0}   ${alias}=ssh-ap-${ue_id}-${ue_comu_id}   ${force}=${False}
    ssh.Connect To   hostname=${tl.ues[${ue_id}].l1.common_units[${ue_comu_id}].lmp_connection.addr}
    ...              username=${tl.ues[${ue_id}].l1.common_units[${ue_comu_id}].lmp_connection.username}
    ...              password=${tl.ues[${ue_id}].l1.common_units[${ue_comu_id}].lmp_connection.password}
    ...              alias=${alias}
    Run Keyword If   ${force}   ssh.Force Reconnect    ${alias}
    [Return]   ${alias}


Connect to Airphone Capacity Unit
    [Documentation]
    ...     setup ssh connection to Phoner (ABXX) and returns connection handle/alias
    ...
    ...     | gnb_id  | Id of ap [0.. ] |
    ...     | comu_id | Id of Common Unit [0..1] |
    ...     | capu_id | Id of Capacity Unit [0..5] |
    ...     | slave   | Name of Slave of Capacity unit (a|b|phoner) |
    ...     | alias   | connection alias, should not be used !! |
    ...     | force   | session reconnection if needed (either True or False) |
    ...
    ...     *Example*
    ...
    ...     | # setup connection to loner
    ...     | ${phoner_alias}   connect.Connect to Airphone Capacity Unit    ue_id=0  ue_comu_id=0  ue_capu_id=0  slave=phoner
    ...     | ssh.execute     command=uptime  connection=${phoner_alias}
    ...
    ...     *Returns*     alias for ssh connection to Capacity Unit
    ...
    [Arguments]    ${ue_id}=${0}   ${ue_comu_id}=${0}   ${ue_capu_id}=${0}   ${slave}=a
    ...    ${alias}=ssh-ue-${ue_id}-${ue_comu_id}-${ue_capu_id}-${slave}   ${force}=${False}
    # setup connection to Airphone Common Unit as ssh hop
    ${ue_comu_alias}   Connect to Airphone Common Unit   ue_id=${ue_id}   ue_comu_id=${ue_comu_id}
    ${ip}   testline-Keywords.Get AP Capacity Slave IP   ue_id=${ue_id}   comu_id=${ue_comu_id}   capu_id=${ue_capu_id}   slave=${slave}
    ssh.Connect To   hostname=${ip}
    ...              username=${tl.ues[${ue_id}].l1.common_units[${ue_comu_id}].lmp_connection.username}
    ...              password=${tl.ues[${ue_id}].l1.common_units[${ue_comu_id}].lmp_connection.password}
    ...              proxy=${ue_comu_alias}
    ...              alias=${alias}
    Run Keyword If   ${force}   ssh.Force Reconnect    ${alias}
    [Return]    ${alias}


Setup OAM http session
    [Documentation]
    ...    set OAM http session for gNB|eNB
    ...
    ...    | node_id            | Id of gNB or eNB [0.. ] |
    ...    | node_type          | either enb or gnb  (gnb|enb) |
    ...    | admin_api_log_path | directory path to store admin api logs |
    ...
    ...    *Returns*     alias for admin API connection to OAM
    ...
    [Arguments]     ${node_id}=${0}   ${node_type}=gnb   ${admin_api_log_path}=${OUTPUT DIR}/admin_logs
    ${node_type}    Convert to lower case           ${node_type}
    ${oam_alias}    Set variable    ${node_type}-${node_id}-OAM-http-session
    ${status}   ${retval}   Run Keyword And Ignore Error   admin.get_sw_release_name   connection=${oam_alias}
    Return From KeyWord If  '${status}'=='PASS'   ${oam_alias}

    # sometimes the alias already exists but get_sw_release_name returns FAIL with e.g. error code 6
    # that's why we conditionally teardown the session here to avoid AliasInUse error in later setup execution
    Run Keyword If   'AliasLookupError' not in $retval   admin.teardown   connection=${oam_alias}

    ${remote_ip}    Get test pc ip for remote connection   node_type=${node_type}   node_id=${node_id}
    Create directory    ${admin_api_log_path}
    BuiltIn.Log     Setup admin connection with Node ${node_type}${node_id} via ${remote_ip}   console=${P_admin_console}
    Wait Until Keyword Succeeds   3min   30sec   admin.setup_admin
    ...     bts_host=192.168.255.129   name=${oam_alias}   remote_host=${remote_ip}   admin_api_log_dir=${admin_api_log_path}
    [Return]   ${oam_alias}


Teardown OAM http session
    [Documentation]
    ...    Teardown OAM http session for given ``node_type``.
    ...
    ...    | node_id   | Id of gNB|eNB [0.. ] |
    ...    | node_type | either enb or gnb (gnb|enb) |
    ...
    [Arguments]   ${node_id}=${0}   ${node_type}=gnb
    ${node_type}   String.Convert to lower case   ${node_type}
    ${oam_alias}   Set Variable   ${node_type}-${node_id}-OAM-http-session
    ${status}   Run keyword And Return Status   admin.teardown   connection=${oam_alias}
    [Return]    ${status}


Reconnect OAM http session
    [Documentation]
    ...     This KW closes and re-connects the admin API session to the given ``node_type``.
    ...
    ...    | node_id   | Id of gNB|eNB [0.. ] |
    ...    | node_type | either enb or gnb (gnb|enb) |
    ...
    ...    *Returns*     alias for http connection to OAM
    ...
    [Arguments]   ${node_type}=gnb   ${node_id}=0
    Teardown OAM http session   node_type=${node_type}   node_id=${node_id}
    ${oam_alias}   Setup OAM Http session   node_type=${node_type}   node_id=${node_id}
    [Return]   ${oam_alias}


Setup eNB OAM session
    [Documentation]
    ...    Setup session to OAM (COAM/CloudCOAM).
    ...
    ...    | enb_id  | Id of enb [0.. ] |
    ...    | comu_id | Id of the common unit |
    ...
    ...    *Returns*     alias for http connection to OAM
    ...
    [Arguments]     ${enb_id}=${0}  ${comu_id}=${0}
    ${oam_alias}    Set variable    enb-${enb_id}-DU-OAM-local-session
    PR555292 WA coam admin connection   ip=${tl.enbs[${enb_id}].system_module.common_units[${comu_id}].lmp_connection.addr}   oam_alias=${oam_alias}
    [Return]   ${oam_alias}


Connect to test pc proxy for node
    [Documentation]
    ...    It is needed when there is different test_pc for each unit of different node type: enb|gnb.
    ...    In such case "tl.test_pc.connections" is required.
    ...
    ...    *Scope*   Internal
    ...
    [Arguments]   ${node_id}   ${node_type}=gnb   ${force}=${False}
    ${node_test_pc}   connect_py.get_test_pc_for_nodeb   ${tl}   ${tl.${node_type}s[${node_id}]}
    ${alias}    Set variable   ${node_type}_${node_id}-test_pc
    ssh.Connect To   hostname=${node_test_pc.default_ssh_connection_details.addr}
    ...              username=${node_test_pc.default_ssh_connection_details.username}
    ...              password=${node_test_pc.default_ssh_connection_details.password}
    ...              alias=${alias}
    Run Keyword If   ${force}   ssh.Force Reconnect    ${alias}
    [Return]   ${alias}


Get Test PC for Object
    [Documentation]
    ...
    ...    *Scope*   Internal
    ...
    [Arguments]    ${obj}
    ${result}    Evaluate    [test_pc for test_pc in $tl.test_pcs for obj in test_pc.connections if obj is $obj][0]
    [Return]    ${result}


PR555292 WA coam admin connection
    [Documentation]
    ...    This KW tries 3 times to setup the oam admin API for the given ``ip``.
    ...
    ...    *Scope*   Internal
    ...
    ...    | ip        | ip of destination node |
    ...    | oam_alias | alias name for the connection |
    ...    | admin_api_log_path | directory path to store admin api logs |
    ...
    [Arguments]   ${ip}   ${oam_alias}   ${admin_api_log_path}=${OUTPUT DIR}/admin_logs
    OperatingSystem.Create Directory   ${admin_api_log_path}
    BuiltIn.Log   Try to establish OAM admin connection 3 times   console=${P_admin_console}
    Wait until keyword succeeds   3min   30sec
    ...   admin.Connect To   bts_host=${ip}   name=${oam_alias}   admin_api_log_dir=${admin_api_log_path}


Get Ssh Connection Parameters
    [Documentation]
    ...    Returns the conection parameters for a given ssh alias
    ...
    ...    | alias | alias name for the connection |
    ...
    ...    *Scope*   Internal
    ...
    [Arguments]   ${alias}
    ${instance}   ssh.Get Connection By Alias   ${alias}
    [Return]   ${instance.params}


Check SSH Alias Exist
    [Documentation]
    ...    Checks whether or not a given alias exists already.
    ...    Can be used to avoid AliasInUse errors.
    ...
    ...    | alias | alias name for the connection |
    ...
    ...    *Scope*   Internal
    ...
    ...    *Returns*   Boolean True if the alias exists and False if not
    ...
    [Arguments]   ${alias}
    ${status}   Run Keyword And Return Status   Get Ssh Connection Parameters   ${alias}
    [Return]   ${status}


Get test pc proxy for ssh connection
    [Documentation]
    ...     This KW returns test pc proxy for ssh connection
    ...
    ...    | node_id   | Id of gNB|eNB [0.. ] |
    ...    | node_type | either enb or gnb (gnb|enb) |
    ...
    ...    *Returns*     alias for ssh connection to test pc
    ...
    [Arguments]   ${node_type}=gnb   ${node_id}=0
    ${node_test_pc}     connect_py.get_test_pc_for_nodeb   ${tl}    ${tl.${node_type}s[${node_id}]}
    ${node_pc_ip}       Set Variable    ${node_test_pc.default_ssh_connection_details.addr}
    ${local_ip}         Set Variable    ${tl.test_pc.default_ssh_connection_details.addr}
    ${local_pc_is_not_node_test_pc}     Run Keyword And Return Status   Should Not Be Equal As Strings    ${node_pc_ip}   ${local_ip}
    ${node_pc_connection_available}     Run Keyword And Return Status   Should Not Be Empty    ${node_test_pc.connections}

    ${proxy}   Run Keyword If   ${node_pc_connection_available} and ${local_pc_is_not_node_test_pc}
    ...        Connect to test pc proxy for node   node_id=${node_id}   node_type=${node_type}
    ...    ELSE
    ...        Set Variable   ${None}
    [Return]   ${proxy}


Get test pc ip for remote connection
    [Documentation]
    ...     This KW returns remote test pc ip
    ...
    ...    | node_id   | Id of gNB|eNB [0.. ] |
    ...    | node_type | either enb or gnb (gnb|enb) |
    ...
    ...    *Returns*     ip for remote test pc
    ...
    [Arguments]   ${node_type}=gnb   ${node_id}=0
    ${nb_test_pc}   connect_py.get_test_pc_for_nodeb   ${tl}   ${tl.${node_type}s[${node_id}]}
    BuiltIn.Log     ${\n}nb_test_pc_ip: ${nb_test_pc.default_ssh_connection_details.addr}   console=${P_admin_console}
    BuiltIn.Log     VM_ip: ${tl.test_pc.default_ssh_connection_details.addr}                console=${P_admin_console}
    ${remote_ip}    Run Keyword If   "${nb_test_pc.default_ssh_connection_details.addr}"=="${tl.test_pc.default_ssh_connection_details.addr}"
    ...             Set Variable    ${None}
    ...     ELSE    Set Variable    ${nb_test_pc.default_ssh_connection_details.addr}
    [Return]        ${remote_ip}

Disconnect All Available ssh Connections
    [Documentation]
    ...    Close all ssh connections and clean the cache.
    ...
    ...    https://taf-transport-ssh.docs.taf.ute.nsn-rdnet.net/en/stable/robot_index.html#Reset%20Cache
    ...
    ssh.reset_cache

Connection.ExecuteUnblock
    [Arguments]     ${cmd}    ${timeout}    ${alias}
    ${result}    ssh.send_command    command=${cmd}    timeout=${timeout}    connection=${alias}
    [Return]    ${result}

Connection.Execute
    [Arguments]     ${cmd}    ${alias}
    ${result}    ssh.execute    command=${cmd}    connection=${alias}
    [return]    ${result}

Connection.ReceiveReply
    [Arguments]    ${size}=10000    ${alias}=${ALIAS_GNB}
    ${result}    ssh.read_output    size=${size}   connection=${alias}
    [Return]    ${result}

Connection.ReceiveUntil
    [Arguments]    ${match}=""   ${alias}=${ALIAS_GNB}
    BuiltIn.log    Conn.ReceiveUntil: match is ${match}
    ssh.await_execution_end    connection=${alias}    timeout=30
    # ${result}    ssh.read_output_until    match=${match}   timeout=30    connection=${alias}
    # [Return]    ${result}

Connection.DownloadFile
    [Arguments]     ${local_path}    ${remote_path}    ${alias}
    ${result}     ssh.download_file    remote_path=${remote_path}    local_path=${local_path}    connection=${alias}
    [Return]    ${result}

Connection.ResetCache
    ssh.reset_cache

Connection.Disconnect
    [Arguments]    ${alias}
    ssh.disconnect    connection=${alias}
