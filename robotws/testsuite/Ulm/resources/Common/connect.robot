*** Settings ***

Documentation   Keywords for connection handling

Library   String
Library   OperatingSystem

Library   taf.sbts.oam.coam.admin          WITH NAME   admin
Library   taf.gnb.oam.coam.cu              WITH NAME   coam_cu
Library   taf.transport.ssh                WITH NAME   ssh

Library   python/connect.py                WITH NAME   connect_py
Library   python/gnb.py                    WITH NAME   gnb_lib

Resource   testline.robot

*** Variables ***
${P_admin_console}              ${False}   # debug output to console for setup oam http connections

*** Keywords ***
Connect To Core
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
    IF  ${force}   ssh.Force Reconnect    ${alias}
    RETURN    ${alias}


Connect To Node Common Unit
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
    ${proxy}    Get Test PC Proxy For SSH Connection    node_type=${node_type}    node_id=${node_id}

    ${parent}   Set Variable If   '${node_type}'=='gnb'   dus[${du_id}].airscale
    ...                           '${node_type}'=='enb'   system_module

    ssh.Connect To   hostname=${tl.${node_type}s[${node_id}].${parent}.common_units[${comu_id}].lmp_connection.addr}
    ...              username=${tl.${node_type}s[${node_id}].${parent}.common_units[${comu_id}].lmp_connection.username}
    ...              password=${tl.${node_type}s[${node_id}].${parent}.common_units[${comu_id}].lmp_connection.password}
    ...              alias=${alias}
    ...              proxy=${proxy}
    IF  ${force}   ssh.Force Reconnect    ${alias}
    RETURN    ${alias}


Connect To GNB Capacity Unit
    [Documentation]
    ...     setup ssh connection to Loner (ABXX) and returns connection handle/alias
    ...
    ...     | gnb_id  | Id of gnb [0.. ] |
    ...     | du_id   | Id of DU [0.. ] |
    ...     | comu_id | Id of Common Unit [0..1] |
    ...     | capu_id | Id of Capacity Unit [0..5] |
    ...     | slave   | Id of Slave of Capacity unit (0|1|2) |
    ...     | alias   | connection alias, should not be used !! |
    ...     | force   | session reconnection if needed (either True or False) |
    ...
    ...     *Example*
    ...
    ...     | # setup connection to fsp<slotId=0>s<socId=2>icom
    ...     | ${loner_alias}   connect.Connect to gNB Capacity Unit    gnb_id=0  du_id=0  comu_id=0  capu_id=0  slave=2
    ...     | ssh.execute     command=uptime  connection=${loner_alias}
    ...
    ...     *Returns*     alias for ssh connection to Capacity Unit
    ...
    [Arguments]    ${gnb_id}=${0}   ${du_id}=${0}   ${comu_id}=${0}   ${capu_id}=${0}   ${slave}=0
    ...            ${alias}=ssh-gnb-${gnb_id}-${du_id}-${comu_id}-${capu_id}-${slave}   ${force}=${False}
    # setup connection to Common Unit as ssh hop
    ${comu_alias}   Connect To Node Common Unit   node_id=${gnb_id}   du_id=${du_id}   comu_id=${comu_id}

    ${board_id}   Evaluate   int(${capu_id}) + 1
    ${slave_ip}   testline_py.Get CPU IP   connection=${comu_alias}   board_id=${board_id}   cpu_id=${slave}

    iputils.Should Be Valid IP     ${slave_ip.strip()}

    ssh.Connect To   hostname=${slave_ip.strip()}
    ...              username=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.username}
    ...              password=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.password}
    ...              proxy=${comu_alias}
    ...              alias=${alias}
    IF  ${force}   ssh.Force Reconnect    ${alias}
    RETURN    ${alias}


Connect To UE PC
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
    IF  ${force}   ssh.Force Reconnect    ${alias}
    RETURN    ${alias}



Connect To UE Application Server
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
    IF  ${force}   ssh.Force Reconnect    ${alias}
    RETURN   ${alias}


Connect To Core Application Server
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
    IF  ${force}   ssh.Force Reconnect    ${alias}
    RETURN   ${alias}


Connect To Airphone Common Unit
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
    IF  ${force}   ssh.Force Reconnect    ${alias}
    RETURN   ${alias}


Connect To Airphone Capacity Unit
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
    ${ue_comu_alias}   Connect To Airphone Common Unit   ue_id=${ue_id}   ue_comu_id=${ue_comu_id}
    ${ip}   testline.Get AP Capacity Slave IP   ue_id=${ue_id}   comu_id=${ue_comu_id}   capu_id=${ue_capu_id}   slave=${slave}
    ssh.Connect To   hostname=${ip}
    ...              username=${tl.ues[${ue_id}].l1.common_units[${ue_comu_id}].lmp_connection.username}
    ...              password=${tl.ues[${ue_id}].l1.common_units[${ue_comu_id}].lmp_connection.password}
    ...              proxy=${ue_comu_alias}
    ...              alias=${alias}
    IF  ${force}   ssh.Force Reconnect    ${alias}
    RETURN    ${alias}


Setup OAM HTTP Session
    [Documentation]
    ...    set OAM http session for gNB|eNB
    ...
    ...    | node_id            | Id of gNB or eNB [0.. ] |
    ...    | node_type          | either enb or gnb  (gnb|enb) |
    ...    | admin_api_log_path | directory path to store admin api logs |
    ...    | timeout            | max time to rety successful Admin API setup (default: 3min) |
    ...
    ...    *Returns*     alias for admin API connection to OAM
    ...
    [Arguments]     ${node_id}=${0}   ${node_type}=gnb   ${admin_api_log_path}=${OUTPUT DIR}/admin_logs   ${timeout}=3min
    ${oam_alias}    connect_py.Setup OAM Http Session   tl=${tl}   node_id=${node_id}   node_type=${node_type}
    ...                                 admin_api_log_path=${admin_api_log_path}   timeout=${timeout}

    RETURN   ${oam_alias}


Teardown OAM HTTP Session
    [Documentation]
    ...    Teardown OAM http session for given ``node_type``.
    ...
    ...    | node_id   | Id of gNB|eNB [0.. ] |
    ...    | node_type | either enb or gnb (gnb|enb) |
    ...
    [Arguments]   ${node_id}=${0}   ${node_type}=gnb
    ${node_type}   String.Convert To Lower Case   ${node_type}
    ${oam_alias}   Set Variable   ${node_type}-${node_id}-OAM-http-session
    ${status}   Run Keyword And Return Status   admin.Teardown   connection=${oam_alias}
    RETURN    ${status}


Reconnect OAM Http Session
    [Documentation]
    ...     This KW closes and re-connects the admin API session to the given ``node_type``.
    ...
    ...    | node_id   | Id of gNB|eNB [0.. ] |
    ...    | node_type | either enb or gnb (gnb|enb) |
    ...
    ...    *Returns*     alias for http connection to OAM
    ...
    [Arguments]   ${node_type}=gnb   ${node_id}=0
    Teardown OAM HTTP Session   node_type=${node_type}   node_id=${node_id}
    ${oam_alias}   Setup OAM HTTP Session   node_type=${node_type}   node_id=${node_id}
    RETURN   ${oam_alias}


Setup ENB OAM Session
    [Documentation]
    ...    Setup session to OAM (COAM/CloudCOAM).
    ...
    ...    | enb_id  | Id of enb [0.. ] |
    ...    | comu_id | Id of the common unit |
    ...
    ...    *Returns*     alias for http connection to OAM
    ...
    [Arguments]     ${enb_id}=${0}  ${comu_id}=${0}
    ${oam_alias}    Set Variable    enb-${enb_id}-DU-OAM-local-session
    PR555292 WA COAM Admin Connection   ip=${tl.enbs[${enb_id}].system_module.common_units[${comu_id}].lmp_connection.addr}   oam_alias=${oam_alias}
    RETURN   ${oam_alias}


Connect To Test PC Proxy For Node
    [Documentation]
    ...    It is needed when there is different test_pc for each unit of different node type: enb|gnb.
    ...    In such case "tl.test_pc.connections" is required.
    ...
    ...    *Scope*   Internal
    ...
    [Arguments]   ${node_id}   ${node_type}=gnb   ${force}=${False}
    ${node_test_pc}   connect_py.Get Test PC For Nodeb   ${tl}   ${tl.${node_type}s[${node_id}]}
    ${alias}    Set Variable   ${node_type}_${node_id}-test_pc
    ssh.Connect To   hostname=${node_test_pc.default_ssh_connection_details.addr}
    ...              username=${node_test_pc.default_ssh_connection_details.username}
    ...              password=${node_test_pc.default_ssh_connection_details.password}
    ...              alias=${alias}
    IF   ${force}   ssh.Force Reconnect    ${alias}
    RETURN   ${alias}


Get Test PC For Object
    [Documentation]
    ...
    ...    *Scope*   Internal
    ...
    [Arguments]    ${obj}
    ${result}    Evaluate    [test_pc for test_pc in $tl.test_pcs for obj in test_pc.connections if obj is $obj][0]
    RETURN    ${result}


PR555292 WA COAM Admin Connection
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
    Log   Try to establish OAM admin connection 3 times   console=${P_admin_console}
    Wait Until Keyword Succeeds   3min   30sec
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
    RETURN   ${instance.params}


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
    RETURN   ${status}


Get Test PC Proxy For SSH Connection
    [Documentation]
    ...     This KW returns test pc proxy for ssh connection
    ...
    ...    | node_id   | Id of gNB|eNB [0.. ] |
    ...    | node_type | either enb or gnb (gnb|enb) |
    ...
    ...    *Returns*     alias for ssh connection to test pc
    ...
    [Arguments]   ${node_type}=gnb   ${node_id}=0
    ${node_test_pc}     connect_py.Get Test PC For Nodeb   ${tl}    ${tl.${node_type}s[${node_id}]}
    ${node_pc_ip}       Set Variable    ${node_test_pc.default_ssh_connection_details.addr}
    ${local_ip}         Set Variable    ${tl.test_pc.default_ssh_connection_details.addr}
    ${local_pc_is_not_node_test_pc}     Run Keyword And Return Status   Should Not Be Equal As Strings    ${node_pc_ip}   ${local_ip}
    ${node_pc_connection_available}     Run Keyword And Return Status   Should Not Be Empty    ${node_test_pc.connections}

    IF   ${node_pc_connection_available} and ${local_pc_is_not_node_test_pc}
        ${proxy}    Connect To Test PC Proxy For Node   node_id=${node_id}   node_type=${node_type}
    ELSE
        ${proxy}    Set Variable   ${None}
    END
    RETURN   ${proxy}



Disconnect All Available SSH Connections
    [Documentation]
    ...    Close all ssh connections and clean the cache.
    ...
    ...    https://taf-transport-ssh.docs.taf.ute.nsn-rdnet.net/en/stable/robot_index.html#Reset%20Cache
    ...
    ssh.Reset Cache

