*** Settings ***
Library     String
Library     taf.transport.ssh             WITH NAME   ssh
Library     ./rrm_fixture.py
Library     ./ue_pc.py
Library     preconditions_py.py

*** Variables ***
${SSH_AUTHENTICATION_TIMEOUT}         10 min
${SSH_AUTHENTICATION_RETRY_INTERVAL}  1
${BTS_TYPE}                           ${tl.gnbs[0].__class__.__name__}


*** Keywords ***
Connect to test PC
    [Arguments]    ${alias}=test_pc
    ssh.Connect_to      hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...                 username=${tl.test_pc.default_ssh_connection_details.username}
    ...                 password=${tl.test_pc.default_ssh_connection_details.password}
    ...                 alias=${alias}
    [Return]    ${alias}


Connect to SMOD
    [Documentation]     Create connection to SMOD (ASIK, ASIB etc)
    [Arguments]      ${alias}=SMOD_MASTER
    ssh.connect_to      hostname=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...                 username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...                 password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...                 alias=${alias}
    [Return]         ${alias}


Connect to SMOD SLAVE
    #
    # 'Set global variables' keyword from preconditions.robot
    #  sets ${smod name} variable and needs to be called beforehand
    #
    [Documentation]     Create connection to SMOD SLAVE (ASIK) via SMOD MASTER proxy. No SMOD SLAVE for ASIB!
    [Arguments]      ${alias}=SMOD_SLAVE
    ${proxy}         connections.Connect to SMOD
    ${smod name}=    Get SMOD Name
    Run Keyword if   '${smod name}' == 'ASIK'
    ...   ssh.connect_to      hostname=192.168.253.2
    ...                       username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...                       password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...                       alias=${alias}
    ...                       proxy=${proxy}
    [Return]         ${alias}


Connect to BBMOD ${bsh_name}
    [Documentation]   Connects with given ABIL session
    ...               ${bsh_name} should be MASTER, SLAVE, LONER, LONER2 or LONER3
    ${bsh_name}=   Convert To Lowercase   ${bsh_name}
    ${alias}=      Convert To Uppercase   ${bsh_name}
    ${hostname}=   Get ABIL hostname      ${bsh_name}
    ${proxy}=      connections.Connect to ASIK

    Run Keyword If   '${BTS_TYPE}' == 'ClassicalBts'
    ...   ssh.connect_to   hostname=${hostname}
    ...                    username=${tl.gnbs[0].du.airscale.common_units[0].lmp_connection.username}
    ...                    password=${tl.gnbs[0].du.airscale.common_units[0].lmp_connection.password}
    ...                    alias=${alias}
    ...                    proxy=${proxy}
    ...   ELSE
    ...   ssh.connect_to   hostname=${hostname}
    ...                    username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...                    password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...                    alias=${alias}
    ...                    proxy=${proxy}
    ssh.Force Reconnect    connection=${alias}
    [Return]      ${alias}


Connect to ${vm_name} from OAM
    ${vm_name}=   Convert To Lowercase   ${vm_name}
    ${alias}=     Convert To Uppercase   ${vm_name}
    ${proxy}=     Connect to OAM
    ssh.connect to   hostname=${vm_name}-0.local
    ...              username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...              password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...              alias=${alias}
    ...              proxy=${proxy}
    [Return]  ${alias}


Connect to OAM
    [Arguments]   ${alias}=OAM
    ssh.Connect to   ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...              ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...              ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...              alias=${alias}
    [Return]      ${alias}


Connect to ASIK
    [Arguments]   ${alias}=ASIK
    Run Keyword If   '${BTS_TYPE}' == 'ClassicalBts'
    ...   ssh.connect_to   hostname=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...                    username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...                    password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...                    alias=${alias}
    ...   ELSE
    ...   ssh.connect_to   hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                    username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...                    password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...                    alias=${alias}
    ssh.Force Reconnect   connection=${alias}
    [Return]      ${alias}


Connect to ABIL ${bsh_name}
    ${alias}=     Connect to BBMOD ${bsh_name}
    [Return]      ${alias}


Connect to gNB
    ${alias}=   Run Keyword If   '${BTS_TYPE}' == 'ClassicalBts'
    ...             connections.Connect to ASIK
    ...         ELSE
    ...             connections.Connect to CPIF from OAM
    ssh.Force Reconnect   connection=${alias}
    [Return]   ${alias}


Connect to EPCsim
    [Arguments]   ${alias}=epcsim
    ssh.Connect To         ${tl.core.default_ssh_connection_details.addr}
    ...                    ${tl.core.default_ssh_connection_details.username}
    ...                    ${tl.core.default_ssh_connection_details.password}
    ...                    alias=${alias}
    [Return]      ${alias}


Connect to UEPC
    [Arguments]   ${alias}=UEPC
    Run Keyword If   '${tl.ues[0].__class__.__name__}' == 'dict'
    ...   _connect to ue with yaml cfg      alias=${alias}
    ...   ELSE IF    '${tl.ues[0].__class__.__name__}' == 'Android'
    ...   run keyword    _connect to ue without yaml cfg   alias=${alias}
    ...   ELSE
    ...   run keyword    _connect to ue with yaml cfg      alias=${alias}
    [Return]      ${alias}


Set UTE Library for Askey UE if needed
    Run Keyword If   ${tl.ues}
    ...   _Set Library for UE


_Set Library for UE
    Run Keyword If   '${tl.ues[0].__class__.__name__}' == 'Android'
    ...   Set Library Search Order  taf.ue
    ...   ELSE
    ...   Set Library Search Order  ute_ue


_connect to ue with yaml cfg
    [Arguments]   ${alias}=UEPC
    ${ue_name}     Get yaml ue name
    ${hostname}    ${username}    ${password}   Get UEPC connection details
    Run Keyword If         '${ue_name}' == 'AT_BASED_UE_1'
    ...   ssh.connect to   hostname=${hostname}
    ...                    username=${username}
    ...                    password=${password}
    ...                    alias=${alias}
    ...   ELSE
    ...   ssh.connect to   hostname=${tl.ues[0]['UE_POOLS']['ViaviUePool']['UE_1']['CONSTRUCTOR_PARAMETERS']['data_transfer']['server']['ip']}
    ...                    username=${tl.ues[0]['UE_POOLS']['ViaviUePool']['UE_1']['CONSTRUCTOR_PARAMETERS']['data_transfer']['server']['uname']}
    ...                    password=${tl.ues[0]['UE_POOLS']['ViaviUePool']['UE_1']['CONSTRUCTOR_PARAMETERS']['data_transfer']['server']['pwd']}
    ...                    alias=${alias}


_connect to ue without yaml cfg
    [Arguments]   ${alias}=UEPC
    Run Keyword If   '${tl.ues[0].__class__.__name__}' == 'TM500'
    ...   ssh.Connect to   hostname=${tl.ues[0].tma_host.addr}
    ...                    username=${tl.ues[0].tma_host.username}
    ...                    password=${tl.ues[0].tma_host.password}
    ...                    alias=${alias}
    ...   ELSE
    ...   ssh.Connect to   ${tl.ues[0].ssh_connection_details.addr}
    ...                    ${tl.ues[0].ssh_connection_details.username}
    ...                    ${tl.ues[0].ssh_connection_details.password}
    ...                    alias=${alias}


Get UEPC connection details
    ${ue_name}     Get yaml ue name
    ${hostname}    Get yaml parameter UEPC   ue_name=${ue_name}
    ...                                      parameter=ue_pc_ip
    ${username}    Get yaml parameter UEPC   ue_name=${ue_name}
    ...                                      parameter=login
    ${password}    Get yaml parameter UEPC   ue_name=${ue_name}
    ...                                      parameter=password
    [Return]    ${hostname}    ${username}    ${password}



Connect to Appserver
    [Arguments]   ${alias}=appserver
    Run Keyword If   "${tl.ues[0].__class__.__name__}" == "dict"
    ...   _connect to appserver with yaml cfg      alias=${alias}
    ...   ELSE
    ...   _connect to appserver without yaml cfg   alias=${alias}
    [Return]      ${alias}

_connect to appserver with yaml cfg
    [Arguments]   ${alias}=appserver
    ${data_transfer}=  Set Variable  ${tl.ues[0]["UE_POOLS"]["ViaviUePool"]["UE_1"]["CONSTRUCTOR_PARAMETERS"]["data_transfer"]}
    ssh.connect to   hostname=${data_transfer["ue_appserver"]["ip"]}
    ...              username=${data_transfer["ue_appserver"]["uname"]}
    ...              password=${data_transfer["ue_appserver"]["pwd"]}
    ...              alias=${alias}

_connect to appserver without yaml cfg
    [Arguments]   ${alias}=appserver
    ssh.Connect To         ${tl.appserver.iperf_details.ssh_connection_details.addr}
    ...                    ${tl.appserver.iperf_details.ssh_connection_details.username}
    ...                    ${tl.appserver.iperf_details.ssh_connection_details.password}
    ...                    alias=${alias}
    [Return]      ${alias}

Connect to LTE test pc
    [Arguments]   ${alias}=lte_pc
    ssh.Connect To         ${tl.test_pcs[0].default_ssh_connection_details.addr}
    ...                    ${tl.test_pcs[0].default_ssh_connection_details.username}
    ...                    ${tl.test_pcs[0].default_ssh_connection_details.password}
    ...                    alias=${alias}
    [Return]      ${alias}


Connect to LTE BTS
    [Arguments]      ${alias}=lte_bts

    ${lte_pc}=       Connect to LTE test pc
    ssh.Connect To   hostname=192.168.255.1
    ...              username=toor4nsn
    ...              password=oZPS0POrRieRtu
    ...              proxy=${lte_pc}
    ...              alias=${alias}

    [Return]         ${alias}


Connect to RealCore
    [Arguments]   ${alias}=realcore
    Run Keyword If   "${tl.ues[0].__class__.__name__}" == "dict"
    ...   _connect to realcore with yaml cfg      alias=${alias}
    ...   ELSE
    ...   _connect to realcore without yaml cfg   alias=${alias}
    [Return]      ${alias}


_connect to realcore with yaml cfg
    [Arguments]   ${alias}=realcore
    ${data_transfer}=  Set Variable  ${tl.ues[0]["UE_POOLS"]["ViaviUePool"]["UE_1"]["CONSTRUCTOR_PARAMETERS"]["data_transfer"]}
    ssh.connect to   hostname=${data_transfer["core_appserver"]["ip"]}
    ...              username=${data_transfer["core_appserver"]["uname"]}
    ...              password=${data_transfer["core_appserver"]["pwd"]}
    ...              alias=${alias}


_connect to realcore without yaml cfg
    [Arguments]   ${alias}=realcore
    ssh.Connect To     hostname=${tl.test_pcs[1].default_ssh_connection_details.addr}
    ...                username=${tl.test_pcs[1].default_ssh_connection_details.username}
    ...                password=${tl.test_pcs[1].default_ssh_connection_details.password}
    ...                alias=${alias}
