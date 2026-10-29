# File copied from: testsuite/Krakow/RRM/RAN_PZ/resources

*** Settings ***
Library     taf.transport.ssh             WITH NAME   ssh
Library     String

*** Variables ***
${SSH_AUTHENTICATION_TIMEOUT}         10 min
${SSH_AUTHENTICATION_RETRY_INTERVAL}  1
${BTS_TYPE}                           ${tl.gnbs[0].__class__.__name__}


*** Keywords ***

Connect to gNB
    ${alias}=   Run Keyword If   '${BTS_TYPE}' == 'ClassicalBts'
    ...             connections.Connect to ASIK
    ...         ELSE
    ...             connections.Connect to CPIF from OAM
    [Return]   ${alias}


Connect to ${vm_name} from OAM
    ${vm_name}=   Convert To Lowercase   ${vm_name}
    ${alias}=     Convert To Uppercase   ${vm_name}
    ${proxy}=     connections.Connect to OAM
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
    [Return]      ${alias}
