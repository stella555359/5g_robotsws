*** Settings ***

Documentation     Keywords for connection handling

Library    taf.sbts.oam.coam.admin            WITH NAME    admin
Library    taf.gnb.oam.coam.cu                WITH NAME    coam_cu
Library    taf.transport.ssh                  WITH NAME    ssh
Library    python/connect.py
Library    python/gnb.py                      WITH NAME    gnb_lib

Resource    ./testline.robot

*** Keywords ***

Connect to TestPC
    [Documentation]   :Author: Soenke Kullberg
    ...     Setup ssh connection to Test PC and returns connection handle/alias
    ...
    ...     **Note:** KW sould be called without arguments
    ...
    ...     :param alias: (optional) alias used for ssh connection
    ...
    ...     :return alias: for ssh connection to Testpc
    ...
    ...     **Example:**
    ...
    ...     | ${tpc_alias}=  connect.Connect to TestPC
    ...     | ssh.execute  command=ls  connection=${tpc_alias}
    ...
    [Arguments]    ${alias}=ssh-test-pc
    ssh.Connect_to      hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...                 username=${tl.test_pc.default_ssh_connection_details.username}
    ...                 password=${tl.test_pc.default_ssh_connection_details.password}
    ...                 alias=${alias}
    [Return]    ${alias}


Connect to OAM
    [Documentation]  :Author: Srihari Janardhan
    ...     Setup ssh connection to OAM and returns connection handle/alias
    ...
    ...     An alias can used as argument, but better use the returned alias.
    ...
    ...     :param gnb_id: (default=0) Id/Number of gNB
    ...     :param alias: (optional) alias used for ssh connection
    ...
    ...     :return alias: alias for ssh connection to OAM
    ...
    ...     **Example:**
    ...
    ...     | ${oam_alias}=  connect.Connect to OAM
    ...     | ssh.execute  command=ls  connection=${oam_alias}
    ...
    [Arguments]  ${gnb_id}=${0}    ${alias}=ssh-gnb-${gnb_id}-oam
    ${proxy}=    Run keyword if    '${tl.test_pc.connections}'!='[]'    Connect to test pc proxy    gnb_id=${gnb_id}
    ...    ELSE    Set variable    ${None}
    ssh.Connect to      hostname=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.addr}
    ...                 username=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.username}
    ...                 password=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.password}
    ...                 alias=${alias}
    ...                 proxy=${proxy}
    [Return]  ${alias}


Connect to gNB VM
    [Documentation]  :Author: Soenke Kullberg
    ...     setup ssh connection to VM
    ...     ssh connection is done via OAM as proxy
    ...     VM FQDN     ${vm_name}-0.local
    ...
    ...     :param  vm_name: Name of virual machine (cpcl|cpif|cpnb|cpue|upue|cpnrt)
    ...     :param  gnb_id: (default=0) Id/Number of gNB
    ...     :param  alias: (optional) alias used for ssh connection
    ...
    ...     :return alias: alias for ssh connection to OAM
    ...
    ...     **Example:**
    ...
    ...     | ${cpue_alias}=  connect.Connect to gNB VM  vm_name=cpue
    ...     | ssh.execute  command=uptime  connection=${cpue_alias}
    ...
    [Arguments]  ${vm_name}     ${gnb_id}=${0}    ${alias}=ssh-gnb-${gnb_id}-${vm_name}
    ${oam_alias}    connect.Connect to OAM  gnb_id=${gnb_id}
    ssh.Connect to      hostname=${vm_name}-0.local
    ...                 username=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.username}   # same as oam
    ...                 password=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.password}   # same as oam
    ...                 proxy=${oam_alias}
    ...                 alias=${alias}
    [Return]  ${alias}


Connect to Core
    [Documentation]    :Author: Soenke Kullberg
    ...     setup ssh connection core and returns connection handle/alias
    ...     KW sould be called without arguments
    ...
    ...     :param alias: (optional) alias used for ssh connection
    ...
    ...     :return alias: alias for ssh connection to OAM
    ...
    [Arguments]    ${alias}=ssh-core
    ssh.Connect_to      hostname=${tl.core.default_ssh_connection_details.addr}
    ...                 username=${tl.core.default_ssh_connection_details.username}
    ...                 password=${tl.core.default_ssh_connection_details.password}
    ...                 alias=${alias}
    [Return]    ${alias}


Connect to gNB Common Unit
    [Documentation]    :Author: Soenke Kullberg
    ...     setup ssh connection to Airscale (ASXX) and returns connection handle/alias
    ...
    ...     :param gnb_id:         Id of gnb                       [0.. ]  default=0
    ...     :param du_id:          Id of DU                        [0.. ]  default=0
    ...     :param comu_id:        Id of Common Unit               [0..1]  default=0
    ...     :param alias:       (optional) connection alias  !! should not be used
    ...
    ...     :returns alias:     alias for ssh connection to Common Unit
    ...
    ...     **Example:**
    ...
    ...     | ${asxx_alias}=   connect.Connect to gNB Common Unit    gnb_id=0  du_id=0  comu_id=0
    ...     | ssh.execute     command=uptime  connection=${asxx_alias}
    ...
    [Arguments]    ${gnb_id}=${0}  ${du_id}=${0}  ${comu_id}=${0}  ${alias}=ssh-gnb-${gnb_id}-${du_id}-${comu_id}
    ${proxy}=    Run keyword if    '${tl.test_pc.connections}'!='[]'    Connect to test pc proxy    gnb_id=${gnb_id}
    ...    ELSE    Set variable    ${None}
    ssh.Connect_to      hostname=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.addr}
    ...                 username=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.username}
    ...                 password=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.password}
    ...                 alias=${alias}
    ...                 proxy=${proxy}
    ssh.Force Reconnect    ${alias}
    [Return]    ${alias}

Connect to eNB Common Unit
    [Documentation]    :Author: Amr Aboushehata, :Editor: Masiar Makkinejad
    ...     setup ssh connection to Airscale (ASXX) and returns connection handle/alias
    ...
    ...     :param enb_id:         Id of enb                       [0.. ]  default=0
    ...     :param du_id:          Id of DU                        [0.. ]  default=0
    ...     :param comu_id:        Id of Common Unit               [0..1]  default=0
    ...     :param alias:       (optional) connection alias  !! should not be used
    ...
    ...     :returns alias:     alias for ssh connection to Common Unit
    ...
    ...     **Example:**
    ...
    ...     | ${asxx_alias}=   connect.Connect to eNB Common Unit    enb_id=0  du_id=0  comu_id=0
    ...     | ssh.execute     command=uptime  connection=${asxx_alias}
    ...
    [Arguments]    ${enb_id}=${0}  ${du_id}=${0}  ${comu_id}=${0}  ${alias}=ssh-enb-${enb_id}-${du_id}-${comu_id}
    ${proxy}=    Run keyword if    '${tl.test_pc.connections}'!='[]'    Connect to test pc proxy for eNB   enb_id=${enb_id}
     ...    ELSE    Set variable    ${None}
    ssh.Connect_to      hostname=${tl.enbs[${enb_id}].airscale.common_units[${comu_id}].lmp_connection.addr}
    ...                 username=${tl.enbs[${enb_id}].airscale.common_units[${comu_id}].lmp_connection.username}
    ...                 password=${tl.enbs[${enb_id}].airscale.common_units[${comu_id}].lmp_connection.password}
    ...                 alias=${alias}
    ...                 proxy=${proxy}
    ssh.Force Reconnect    ${alias}
    [Return]    ${alias}


Connect to gNB Capacity Unit
    [Documentation]    :Author: Soenke Kullberg
    ...     setup ssh connection to Loner (ABXX) and returns connection handle/alias
    ...
    ...     :param gnb_id:      Id of gnb                       [0.. ]  default=0
    ...     :param du_id:       Id of DU                        [0.. ]  default=0
    ...     :param comu_id:     Id of Common Unit               [0..1]  default=0
    ...     :param capu_id:     Id of Capacity Unit             [0..5]  default=0
    ...     :param slave:       Name of Slave of Capacity unit  a,b,loner       default=a (Master)
    ...     :param alias:       (optional) connection alias  !! should not be used
    ...
    ...     :returns alias:     alias for ssh connection to Capacity Unit
    ...
    ...     **Example:**
    ...
    ...     | # setup connection to loner
    ...     | ${loner_alias}=   connect.Connect to gNB Capacity Unit    gnb_id=0  du_id=0  comu_id=0  capu_id=0  slave=loner
    ...     | ssh.execute     command=uptime  connection=${loner_alias}
    ...
    [Arguments]    ${gnb_id}=${0}  ${du_id}=${0}  ${comu_id}=${0}  ${capu_id}=${0}  ${slave}=a
    ...     ${alias}=ssh-gnb-${gnb_id}-${du_id}-${comu_id}-${capu_id}-${slave}
    # setup connection to Common Unit as ssh hop
    ${comu_alias}=  Connect to gNB Common Unit  gnb_id=${gnb_id}  du_id=${du_id}  comu_id=${comu_id}
    ${ip}=  testline.Get Capacity Slave IP   gnb_id=${gnb_id}  du_id=${du_id}  comu_id=${comu_id}  capu_id=${capu_id}    slave=${slave}
    ssh.Connect_to      hostname=${ip}
    ...                 username=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.username}
    ...                 password=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.password}
    ...                 proxy=${comu_alias}
    ...                 alias=${alias}
    [Return]    ${alias}


Connect to UE PC
    [Documentation]   :Author: Jing Liang
    ...     Setup ssh connection to UE control PC
    ...
    ...     :param ue_id: (optional) ue id
    ...     :param alias: (optional) alias used for ssh connection
    ...
    ...     :return: alias for ssh connection to Testpc
    ...
    [Arguments]    ${ue_id}=${0}    ${alias}=ssh-ue-pc-${ue_id}
    ssh.Connect to    hostname=${tl.ues[${ue_id}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_id}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_id}].ssh_connection_details.password}
    ...    alias=${alias}
    [Return]    ${alias}


Connect to TMA Pc
    [Documentation]   :Author: Vasileios Papoutsis
    ...     Setup ssh connection to TMA PC and\n
    ...     returns connection handle/alias
    ...
    ...     *Note:* KW sould be called without arguments
    ...
    ...     :param ue_id: (optional) ue id
    ...     :param alias: (optional) alias used for ssh connection
    ...
    ...     :return: alias for ssh connection to TMA Pc
    ...
    ...     **Example:**
    ...
    ...     | ${alias}=  connect.Connect to TMA Pc
    ...     | ssh.execute  command=ls  connection=${alias}
    ...
    [Arguments]    ${ue_id}=${0}    ${alias}=ssh-tma-pc-${ue_id}
    ssh.connect_to    hostname=${tl.ues[${ue_id}].tma_host.addr}
    ...    username=${tl.ues[${ue_id}].tma_host.username}
    ...    password=${tl.ues[${ue_id}].tma_host.password}
    ...    alias=${alias}
    [Return]    ${alias}


Connect to UE application server
    [Documentation]   :Author: Vasileios Papoutsis
    ...     Setup ssh connection to UE appserv PC and\n
    ...     returns connection handle/alias
    ...     *Note:* KW sould be called without arguments
    ...
    ...     :param ue_id: (optional) ue id
    ...     :param alias: (optional) alias used for ssh connection
    ...
    ...     :return: alias for ssh connection to UE appserv
    ...
    ...     **Example:**
    ...
    ...     | ${alias}=  connect.Connect to UE appserv
    ...     | ssh.execute  command=ls  connection=${alias}
    ...
    [Arguments]    ${ue_id}=${0}    ${alias}=ssh-ue-${ue_id}-appserv
    ssh.connect_to    hostname=${tl.ues[${ue_id}].iperf_details.ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_id}].iperf_details.ssh_connection_details.username}
    ...    password=${tl.ues[${ue_id}].iperf_details.ssh_connection_details.password}
    ...    alias=${alias}
    [Return]    ${alias}


Connect to core application server
    [Documentation]   :Author: Vasileios Papoutsis
    ...     Setup ssh connection to core appserv PC and\n
    ...     returns connection handle/alias
    ...     *Note:* KW sould be called without arguments
    ...
    ...     :param alias: (optional) alias used for ssh connection
    ...
    ...     :return: alias for ssh connection to core appserv
    ...
    ...     **Example:**
    ...
    ...     | ${alias}=  connect.Connect to core appserv
    ...     | ssh.execute  command=ls  connection=${alias}
    ...
    [Arguments]    ${alias}=ssh-core-appserv
    ssh.connect_to    hostname=${tl.appserver.iperf_details.ssh_connection_details.addr}
    ...    username=${tl.appserver.iperf_details.ssh_connection_details.username}
    ...    password=${tl.appserver.iperf_details.ssh_connection_details.password}
    ...    alias=${alias}
    [Return]    ${alias}


Connect to Airphone Common Unit
    [Documentation]    :Author: Jing Liang
    ...     setup ssh connection to Airphone Airscale (ASXX) and returns connection handle/alias
    ...
    ...     :param ue_id:             Id of UE                       [0.. ]  default=0
    ...     :param ue_comu_id:        Id of AP Common Unit           [0..1]  default=0
    ...     :param alias:       (optional) connection alias  !! should not be used
    ...
    ...     :returns alias:     alias for ssh connection to Common Unit
    ...
    ...     **Example:**
    ...
    ...     | ${ap_alias}=   connect.Connect to Airphone Common Unit    ue_id=0  ue_comu_id=0
    ...     | ssh.execute     command=uptime  connection=${ap_alias}
    ...
    [Arguments]    ${ue_id}=${0}    ${ue_comu_id}=${0}  ${alias}=ssh-ap-${ue_id}-${ue_comu_id}
    ssh.Connect_to      hostname=${tl.ues[${ue_id}].l1.common_units[${ue_comu_id}].lmp_connection.addr}
    ...                 username=${tl.ues[${ue_id}].l1.common_units[${ue_comu_id}].lmp_connection.username}
    ...                 password=${tl.ues[${ue_id}].l1.common_units[${ue_comu_id}].lmp_connection.password}
    ...                 alias=${alias}
    ssh.Force Reconnect    connection=${alias}
    [Return]    ${alias}


Connect to Airphone Capacity Unit
    [Documentation]    :Author: Vasileios Papoutsis
    ...     setup ssh connection to Phoner (ABXX) and returns connection handle/alias
    ...
    ...     :param gnb_id:      Id of ap                        [0.. ]  default=0
    ...     :param comu_id:     Id of Common Unit               [0..1]  default=0
    ...     :param capu_id:     Id of Capacity Unit             [0..5]  default=0
    ...     :param slave:       Name of Slave of Capacity unit  a,b,phoner       default=a (Master)
    ...     :param alias:       (optional) connection alias  !! should not be used
    ...
    ...     :returns alias:     alias for ssh connection to Capacity Unit
    ...
    ...     **Example:**
    ...
    ...     | # setup connection to loner
    ...     | ${phoner_alias}=   connect.Connect to Airphone Capacity Unit    ue_id=0  ue_comu_id=0  ue_capu_id=0  slave=phoner
    ...     | ssh.execute     command=uptime  connection=${phoner_alias}
    ...
    [Arguments]    ${ue_id}=${0}  ${ue_comu_id}=${0}  ${ue_capu_id}=${0}  ${slave}=a
    ...    ${alias}=ssh-ue-${ue_id}-${ue_comu_id}-${ue_capu_id}-${slave}
    # setup connection to Airphone Common Unit as ssh hop
    ${ue_comu_alias}=  Connect to Airphone Common Unit  ue_id=${ue_id}  ue_comu_id=${ue_comu_id}
    ${ip}=  testline.Get AP Capacity Slave IP   ue_id=${ue_id}  comu_id=${ue_comu_id}  capu_id=${ue_capu_id}  slave=${slave}
    ssh.Connect_to      hostname=${ip}
    ...                 username=${tl.ues[${ue_id}].l1.common_units[${ue_comu_id}].lmp_connection.username}
    ...                 password=${tl.ues[${ue_id}].l1.common_units[${ue_comu_id}].lmp_connection.password}
    ...                 proxy=${ue_comu_alias}
    ...                 alias=${alias}
    [Return]    ${alias}


Setup OAM session
    [Documentation]    :Author: Soenke Kullberg
    ...    setup session to OAM (COAM/CloudCOAM)
    ...
    ...    :param gnb_id:      Id of gnb                       [0.. ]  default=0
    ...    :param component: (default=DU, options : DU/CU) If oam type is cloud coam for vRAN 1.0
    ...          the DU component is commissioned by default
    ...
    ...    :returns alias:     alias for http connection to OAM
    [Arguments]     ${gnb_id}=${0}  ${du_id}=${0}  ${component}=DU
    ${oam_alias}=    Set variable    gnb-${gnb_id}-${component}-OAM-local-session
    ${oam_type}=     testline.Get OAM type    gnb_id=${gnb_id}
    ${du_host_ip}=   gnb_lib.Get GNB DU Host IP   ${tl.gnbs[${gnb_id}].dus[${du_id}]}
    Run keyword if    '${oam_type}'=='cloud_coam' and '${component}'=='DU'
    ...    PR555292 WA coam admin connection  ip=${du_host_ip}    oam_alias=${oam_alias}
    ...    ELSE IF    '${oam_type}'=='cloud_coam' and '${component}'=='CU'
    ...    connect admin CU    gnb_id=${gnb_id}    alias=${oam_alias}
    ...    ELSE IF    '${oam_type}'=='coam'
    ...    PR555292 WA coam admin connection  ip=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}    oam_alias=${oam_alias}
    ...    ELSE    Fail    Unknown OAM Type ${oamType}
    [Return]    ${oam_alias}


Setup eNB OAM session
    [Documentation]    :Author: Amr Aboushehata
    ...    setup session to OAM (COAM/CloudCOAM)
    ...
    ...    :param enb_id:      Id of enb                       [0.. ]  default=0
    ...
    ...    :returns alias:     alias for http connection to OAM
    [Arguments]     ${enb_id}=${0}  ${comu_id}=${0}
    ${oam_alias}=    Set variable    enb-${enb_id}-DU-OAM-local-session
    PR555292 WA coam admin connection  ip=${tl.enbs[${enb_id}].airscale.common_units[${comu_id}].lmp_connection.addr}  oam_alias=${oam_alias}
    [Return]    ${oam_alias}


Teardown OAM session
    [Documentation]    :Author: Vasileios Papoutsis
    ...    Teardown session to OAM (COAM/CloudCOAM)
    ...
    ...    :param connection:      Name or the alias for the connection to OAM that was setup using keyword "Setup OAM session"
    ...    :param gnb_id:      Id of gnb                       [0.. ]  default=0
    ...    :param component: (default=DU, options : DU/CU) If oam type is cloud coam for vRAN 1.0
    ...          the DU component is commissioned by default
    [Arguments]    ${connection}=${None}    ${gnb_id}=${0}    ${component}=DU
    ${connection}=    Set Variable If    '${connection}'=='${None}'    gnb-${gnb_id}-${component}-OAM-local-session    ${connection}
    ${oam_type}=    testline.Get OAM type    gnb_id=${gnb_id}
    Run keyword if    '${oam_type}'=='cloud_coam' and '${component}'=='DU'     admin.teardown    connection=${connection}
    ...    ELSE IF    '${oam_type}'=='cloud_coam' and '${component}'=='CU'     coam_cu.disconnect    connection=${connection}
    ...    ELSE IF    '${oam_type}'=='coam'         admin.teardown    connection=${connection}
    ...    ELSE    Fail    Unknown OAM Type ${oamType}


Connect to test pc proxy
    [Documentation]    :Author: Vasileios Papoutsis, [PRIVATE]
    ...    It is needed when there is different test_pc for each unit.
    ...    In such case "tl.test_pc.connections" is required
    [Arguments]    ${gnb_id}
    ${gnb_test_pc}=    Get Test PC for NodeB   ${tl}    ${tl.gnbs[${gnb_id}]}
    ${alias}=    Set variable    gnb-${gnb_id}-test_pc
    ssh.Connect_to      hostname=${gnb_test_pc.default_ssh_connection_details.addr}
    ...                 username=${gnb_test_pc.default_ssh_connection_details.username}
    ...                 password=${gnb_test_pc.default_ssh_connection_details.password}
    ...                 alias=${alias}
    [Return]    ${alias}


Connect to test pc proxy for eNB
    [Documentation]    :Author: Vasileios Papoutsis, :Editor: Masiar Makkinejad
    ...    It is needed when there is different test_pc for each unit.
    ...    In such case "tl.test_pc.connections" is required
    [Arguments]    ${enb_id}
    ${enb_test_pc}=    Get Test PC for NodeB   ${tl}    ${tl.enbs[${enb_id}]}
    ${alias}=    Set variable    enb-${enb_id}-test_pc
    ssh.Connect_to      hostname=${enb_test_pc.default_ssh_connection_details.addr}
    ...                 username=${enb_test_pc.default_ssh_connection_details.username}
    ...                 password=${enb_test_pc.default_ssh_connection_details.password}
    ...                 alias=${alias}
    [Return]    ${alias}


Get Test PC for Object
    [Documentation]    :Author: Vasileios Papoutsis, [PRIVATE]
    [Arguments]    ${obj}
    ${result}=    Evaluate    [test_pc for test_pc in $tl.test_pcs for obj in test_pc.connections if obj is $obj][0]
    [Return]    ${result}


Connect to gNB Cloud CPIF
    [Arguments]  ${gnb_id}
    ${alias}=    Set variable    gnb-${gnb_id}-cpif
    &{oam_ssh_config}=  Create Dictionary
    ...     host=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.addr}
    ...     user=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.username}
    ...     password=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.password}
    &{vm_ssh_config}=    Create dictionary
    ...         host=cpif-0.local
    ...         user=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.username}
    ...         password=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.password}
    ...         proxy=${oam_ssh_config}


connect admin CU
    [Documentation]    [PRIVATE]    start connection to cloud coam CU
    ...     :Autor: Sylvia Schneider
    ...     :param ${gnb_id}: gnb instance in init file
    ...     :param ${alias}:  alias name for connection
    [Arguments]     ${gnb_id}=0  ${alias}=${None}
    ${cu_conn}=    coam_cu.connect_to
    ...     host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}
    ...     port=${EMPTY}
    ...     username=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.username}
    ...     password=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.password}
    ...     cu_version=cuoam_19b
    ...     secure=${True}
    ...     alias=${alias}


PR555292 WA coam admin connection
    [Documentation]    [PRIVATE]
    ...    check this pronto once a week
    ...    https://pronto.int.net.nokia.com/pronto/problemReport.html?prid=PR555292
    [Arguments]    ${ip}    ${oam_alias}
    BuiltIn.Log    to WA PR555292 try to establish OAM connection 3 times
    Wait until keyword succeeds    3 min    30 sec    admin.connect_to    bts_host=${ip}  name=${oam_alias}
