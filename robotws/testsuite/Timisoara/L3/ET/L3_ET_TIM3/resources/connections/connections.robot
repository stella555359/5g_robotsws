*** Settings ***
Documentation    Connection keywords, variables (IP addresses etc.).

Library    taf.transport.ssh        WITH NAME   ssh
Library    OperatingSystem
Library    SSHLibrary

*** Variables ***
${LMP_IP}                   ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${ROOT_USERNAME}            ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${ROOT_PASSWORD}            ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${BACKHAUL_OAM_IP}=         ${tl.gnbs[0].cu.backhaul_site_oam_ip}

*** Keywords ***
Connect to BTS
    [Documentation]    SSH to BTS, by default with BTS LMP IP address.
    [Arguments]        ${ip_address}=${LMP_IP}  ${username}=${ROOT_USERNAME}
    ...                ${password}=${ROOT_PASSWORD}  ${proxy}=${None}  ${port}=22
    ...                ${alias}=cOAM_toor4nsn
    ${connection}=     ssh.Connect to  ${ip_address}
    ...                                ${username}
    ...                                ${password}
    ...                                port=${port}
    ...                                proxy=${proxy}
    ...                                alias=${alias}
    Log                Successfully connected with BTS
    ...                console=${TRUE}
    [Return]           ${connection}

Connect to RU from SMOD via SSH
    [Arguments]                         ${user}  ${password}  ${RU_IP}=${None}
    ${RU_IP}=                           Run Keyword If    '${RU_IP}' == '${None}'    Get RU IP
    ...                                 ELSE              Set Variable               ${RU_IP}
    SSHLibrary.Open Connection          host=${LMP_IP}
    SSHLibrary.Login                    username=${ROOT_USERNAME}       password=${ROOT_PASSWORD}
    SSHLibrary.Write                    text=lxc-attach -n 0x1018
    SSHLibrary.Read Until               expected=FHNET00:~ >
    SSHLibrary.Write                    text=echo "" > /user/toor4nsn/.ssh/known_hosts
    SSHLibrary.Read Until               expected=FHNET00:~ >
    SSHLibrary.Write                    text=ssh ${user}@${RU_IP}
    ${continue}=                        Run keyword and return status
    ...                                 SSHLibrary.Read Until               expected=(yes/no/[fingerprint])?
    Run keyword if   ${continue}        SSHLibrary.Write                    text=yes
    ...              ELSE               SSHLibrary.Write                    text=wrong_password
    Sleep            time_=20s          reason=Waiting for password prompt...
    SSHLibrary.Read Until               expected=password:
    SSHLibrary.Write                    text=${password}
    Run Keyword If                      """${user}""" == """root"""
    ...                                 SSHLibrary.Read Until               expected=#
    ...                 ELSE            SSHLibrary.Read Until               expected=$
    SSHLibrary.Write                    text=\
    ${RU_prompt}=                       Run Keyword If                      """${user}""" == """root"""
    ...                                 SSHLibrary.Read Until               expected=#
    ...                 ELSE            SSHLibrary.Read Until               expected=$
    SSHLibrary.Set Client Configuration     prompt=${RU_prompt}

Connect with SSH
    [Arguments]     ${ip_addr}  ${user}  ${password}  ${alias}
    ${connection}=  ssh.Connect to           ${ip_addr}
    ...                                      ${user}
    ...                                      ${password}
    ...                                      alias=${alias}
    Log             Successfully connected as ${user} at ${ip_addr}
    ...             console=${TRUE}
    [Return]        ${connection}

Disconnect from BTS
    [Arguments]     ${connection}=cOAM_toor4nsn
    ssh.disconnect  ${connection}

Disconnect SSH Session
    [Arguments]     ${connection}
    ssh.disconnect  ${connection}

Get RU IP
    ssh.Connect to    hostname=${LMP_IP}           username=${ROOT_USERNAME}
    ...               password=${ROOT_PASSWORD}    alias=bts_connection
    ${ip}=            ssh.execute    command=cat /ffs/run/config/FRIps.txt | cut -d";" -f3
    ...                              connection=bts_connection
    ssh.disconnect                   connection=bts_connection
    [Return]          ${ip}

Ping BTS Mplane IP
    ${output}=  Run  ping -c 2 ${BACKHAUL_OAM_IP}

Check If BTS Is Pingable
    [Arguments]    ${ip}=${BACKHAUL_OAM_IP}
    ${output}=    Run    ping -c 1 -W 10 ${ip}
    Should contain    ${output}    1 packets transmitted, 1 received

Check If BTS Is Not Pingable
    [Arguments]    ${ip}=${BACKHAUL_OAM_IP}
    ${output}=    Run    ping -c 1 -W 10 ${ip}
    Should contain    ${output}    1 packets transmitted, 0 received

Get VM IPv4 Address
    ${source_ipv4}=  Run  ip a | grep eth0 -A 2 | grep -w inet | awk {'print $2'} | awk -F/ {'print $1'}
    [Return]  ${source_ipv4}
